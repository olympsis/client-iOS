//
//  InAppNotification.swift
//  NotificationKit
//
//  A generic, app-agnostic in-app notification payload.
//  This module must not reference any app-specific types or assets.
//

import SwiftUI

/// The haptic feedback played when a notification card slides in.
public enum InAppNotificationHaptic {
    case impactLight
    case impactMedium
    case success
    case warning
    case error
}

/// Everything needed to display one in-app notification toast.
///
/// Create one and hand it to `InAppNotificationPresenter.shared.present(_:)`.
/// The string-based initializer treats title/subtitle as inline Markdown, so
/// `"**Jane** joined your event"` renders with "Jane" in bold.
public struct InAppNotification: Identifiable {
    public let id: UUID

    /// Optional key used to collapse duplicates. If a notification with the
    /// same `coalesceID` is already waiting in the queue, the new one replaces
    /// it in place instead of being appended (e.g. a burst of comment pushes
    /// for the same thread shows one card, not five).
    public var coalesceID: String?

    public var title: AttributedString
    public var subtitle: AttributedString?

    /// Leading slot — typically an avatar. Rendered as a circle by default.
    public var leadingImage: InAppNotificationImage
    /// Trailing slot — typically content art (event photo, post thumbnail).
    public var trailingImage: InAppNotificationImage

    /// Seconds on screen before auto-dismiss. The presenter pauses this clock
    /// while the user is dragging the card.
    public var duration: TimeInterval
    public var haptic: InAppNotificationHaptic?
    /// When false, the card cannot be swiped away and stays until dismissed
    /// programmatically (or by tap, which always dismisses).
    public var isDismissible: Bool

    public var onTap: (() -> Void)?
    public var onDismiss: (() -> Void)?

    public init(
        id: UUID = UUID(),
        title: AttributedString,
        subtitle: AttributedString? = nil,
        leadingImage: InAppNotificationImage = .none,
        trailingImage: InAppNotificationImage = .none,
        coalesceID: String? = nil,
        duration: TimeInterval = 4,
        haptic: InAppNotificationHaptic? = .impactLight,
        isDismissible: Bool = true,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.leadingImage = leadingImage
        self.trailingImage = trailingImage
        self.coalesceID = coalesceID
        self.duration = duration
        self.haptic = haptic
        self.isDismissible = isDismissible
        self.onTap = onTap
        self.onDismiss = onDismiss
    }

    /// Primary authoring path: plain strings parsed as inline Markdown.
    /// Parsing never throws — invalid Markdown degrades to plain text.
    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        leadingImage: InAppNotificationImage = .none,
        trailingImage: InAppNotificationImage = .none,
        coalesceID: String? = nil,
        duration: TimeInterval = 4,
        haptic: InAppNotificationHaptic? = .impactLight,
        isDismissible: Bool = true,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(
            id: id,
            title: .inAppMarkdown(title),
            subtitle: subtitle.map { .inAppMarkdown($0) },
            leadingImage: leadingImage,
            trailingImage: trailingImage,
            coalesceID: coalesceID,
            duration: duration,
            haptic: haptic,
            isDismissible: isDismissible,
            onTap: onTap,
            onDismiss: onDismiss
        )
    }
}
