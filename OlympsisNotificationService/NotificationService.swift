//
//  NotificationService.swift
//  OlympsisNotificationService
//
//  Created by Joel Joseph on 6/13/26.
//

import os
import UserNotifications

/// Localizes the lean event push notifications on-device.
///
/// The server sends an English `title`/`body` (the literal fallback the
/// system shows if this extension can't run) plus localization
/// instructions in custom payload keys:
///   - `loc_key`        : key into the bundled `Notifications` table → body
///   - `loc_args`       : string args substituted into the body format
///   - `title_loc_key`  : optional key → title (omit to keep the literal,
///                        e.g. the dynamic event name)
///   - `title_loc_args` : optional args for the title
///
/// It also downloads `event_image_url` and attaches it as the notification's
/// trailing thumbnail.
///
/// If a key isn't bundled, the image fails to download, or the extension is
/// killed (30s budget / low memory), the notification is still delivered —
/// with the localized text it managed to set, or the original literal
/// `title`/`body` as a last resort.
final class NotificationService: UNNotificationServiceExtension {

    /// String catalog (xcstrings) bundled into this extension target.
    private let table = "Notifications"

    /// Diagnostics. View in Console.app (or `log stream`) filtered to
    /// subsystem `com.olympsis.client` / category `notification_service`.
    private let log = Logger(subsystem: "com.olympsis.client", category: "notification_service")

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttempt: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        let content = request.content.mutableCopy() as? UNMutableNotificationContent
        self.bestAttempt = content

        guard let content else {
            contentHandler(request.content)
            return
        }

        let userInfo = request.content.userInfo
        log.info("didReceive fired. keys: \(userInfo.keys.map { "\($0)" }.joined(separator: ", "), privacy: .public)")

        // Body: localize when a key is provided and bundled; otherwise the
        // literal `body` from the payload is left untouched.
        if let bodyKey = userInfo["loc_key"] as? String,
           let body = localized(bodyKey, args: stringArgs(userInfo["loc_args"])) {
            content.body = body
        }

        // Title: optional. Absent for notes whose title is dynamic data
        // (the event name); present when the title itself is a template.
        if let titleKey = userInfo["title_loc_key"] as? String,
           let title = localized(titleKey, args: stringArgs(userInfo["title_loc_args"])) {
            content.title = title
        }

        // Trailing image. Every event note carries `event_image_url` (a
        // storage path); download it and attach so the banner shows a
        // thumbnail. If anything fails we still deliver the localized text.
        guard let imagePath = userInfo["event_image_url"] as? String,
              let url = imageURL(for: imagePath) else {
            log.error("No event_image_url / invalid URL — delivering without image.")
            contentHandler(content)
            return
        }

        log.info("Downloading attachment: \(url.absoluteString, privacy: .public)")
        downloadAttachment(from: url) { [log] attachment in
            if let attachment {
                content.attachments = [attachment]
                log.info("Attachment added.")
            } else {
                log.error("Attachment download/creation failed — delivering without image.")
            }
            contentHandler(content)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Out of time — deliver whatever we have (localized if we got to
        // it, otherwise the original literal alert).
        if let contentHandler, let bestAttempt {
            contentHandler(bestAttempt)
        }
    }

    // MARK: - Helpers

    /// Looks `key` up in the bundled `Notifications` table for the device
    /// language and substitutes `args`. Returns `nil` when the key isn't in
    /// the table, so the caller falls back to the literal alert text.
    ///
    /// Numeric args are passed as `Int` so `%lld` specifiers and plural
    /// rules resolve; everything else is passed as `String` for `%@`. Keep
    /// the catalog's specifiers matched: numbers → `%lld`, text → `%@`.
    private func localized(_ key: String, args: [String]) -> String? {
        // NSLocalizedString returns `value` when the key isn't found, so a
        // sentinel lets us detect a missing key.
        let missing = "\u{0}"
        let format = NSLocalizedString(key, tableName: table, bundle: .main, value: missing, comment: "")
        guard format != missing else { return nil }
        guard !args.isEmpty else { return format }

        // Numeric args become `Int` (so `%lld` / plural rules resolve);
        // everything else stays a `String` for `%@`.
        let arguments: [CVarArg] = args.map { arg -> CVarArg in
            if let number = Int(arg) { return number }
            return arg
        }
        return String(format: format, locale: .current, arguments: arguments)
    }

    /// Coerces the JSON `loc_args` value into `[String]`, tolerating a
    /// missing or malformed value.
    private func stringArgs(_ value: Any?) -> [String] {
        value as? [String] ?? []
    }

    // MARK: - Image Attachment

    /// Base URL for Olympsis media in Google Cloud Storage. Mirrors the
    /// app's `generateImageURL` — kept inline so the extension stays
    /// self-contained (it doesn't link the app's code).
    private let imageBaseURL = "https://storage.googleapis.com/olympsis-"

    /// Builds the full media URL from a stored relative path
    /// (e.g. `event-media/abc.jpg`).
    private func imageURL(for path: String) -> URL? {
        URL(string: imageBaseURL + path)
    }

    /// Downloads `url` to a temporary file and wraps it in a
    /// `UNNotificationAttachment`. Calls back with `nil` on any failure so
    /// the notification can still be delivered without an image.
    private func downloadAttachment(from url: URL,
                                    completion: @escaping (UNNotificationAttachment?) -> Void) {
        URLSession.shared.downloadTask(with: url) { [log] tempURL, response, error in
            if let error {
                log.error("Download error: \(error.localizedDescription, privacy: .public)")
            }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                log.error("Download HTTP \(http.statusCode, privacy: .public) for \(url.absoluteString, privacy: .public)")
            }
            guard let tempURL else {
                completion(nil)
                return
            }

            // Move the download to a uniquely named file, preserving the
            // extension so the system can infer the media type. The system
            // copies the file into its attachment store, so this temp file
            // doesn't need to outlive the call.
            let fileManager = FileManager.default
            let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            let destination = fileManager.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)

            do {
                try fileManager.moveItem(at: tempURL, to: destination)
                let attachment = try UNNotificationAttachment(identifier: "event-image", url: destination)
                completion(attachment)
            } catch {
                log.error("Attachment write/create failed: \(error.localizedDescription, privacy: .public)")
                completion(nil)
            }
        }.resume()
    }
}
