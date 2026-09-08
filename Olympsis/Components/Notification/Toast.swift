//
//  Toast.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/6/26.
//

import SwiftUI

/// Short-lived feedback presented through NotificationKit's in-app card.
///
/// This is deliberately a thin wrapper: it exists so call sites read as
/// `Toast.error("…")` instead of hand-assembling an `InAppNotification` with
/// the right image, haptic and duration each time, which is how the two
/// spellings of "something failed" drift apart.
///
/// IMPORTANT: the notification host is an `.overlay(alignment: .top)` on the
/// screen that installs it, so a toast renders *behind* any presented `.sheet`
/// or `.fullScreenCover`. Never toast from inside a sheet (RSVPSheet, NewEvent,
/// …) — those need inline feedback. Screens pushed in a NavigationStack, and
/// the auth screens, are fine.
enum Toast {

    /// A failure the user should notice but can't act on right now.
    ///
    /// No subtitle: `message` is already the full sentence, and a second line
    /// of filler makes the card taller without saying more.
    @MainActor
    static func error(_ message: String) {
        InAppNotificationPresenter.shared.present(
            InAppNotification(
                title: message,
                leadingImage: .system("exclamationmark.triangle.fill", tint: .red),
                haptic: .error
            )
        )
    }

    /// Confirmation that something the user asked for actually happened.
    ///
    /// Shorter than the 4s default: a confirmation has nothing to read past the
    /// first glance, and lingering makes it feel like an error.
    @MainActor
    static func success(_ message: String, systemImage: String = "checkmark.circle.fill") {
        InAppNotificationPresenter.shared.present(
            InAppNotification(
                title: message,
                leadingImage: .system(systemImage, tint: Color.Brand.primary),
                duration: 2,
                haptic: .success
            )
        )
    }
}
