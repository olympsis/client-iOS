//
//  Error.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

enum EventError: Error {
    case unknown
    case failedToAddParticipant
    case failedToRemoveParticipant
    case failedToAddTeam
    case failedToRemoveTeam
    case failedToAddComment
    case failedToRemoveComment
    case serverError
}

enum NewEventError: Error {
    case unknown(message: String)
    case unsafeMedia
    case invalidData
    case serverError(message: String)
}

extension NEW_EVENT_ERROR {
    /// What to tell the user about a failed validation pass.
    ///
    /// `validateEvent` already scrolls to the offending field and tints it, but
    /// colour alone says only "something here" — and `.noTitle` has no tint at
    /// all — so the alert carries the actual instruction.
    var message: String {
        switch self {
        case .noTitle:
            return String(localized: "new-event-error-no-title", table: "Events")
        case .noDescription:
            return String(localized: "new-event-error-no-description", table: "Events")
        case .noSelectedField:
            return String(localized: "new-event-error-no-venue", table: "Events")
        case .badRecurrence:
            return String(localized: "new-event-error-recurrence-end", defaultValue: "The repeat end date must be after the event starts.", table: "Events")
        case .unexpected:
            // The only guard that raises `.unexpected` is end-date <= start-date.
            return String(localized: "new-event-error-bad-dates", table: "Events")
        }
    }
}

extension NewEventError {
    /// User-facing text for a creation failure.
    ///
    /// The `message` payloads on `unknown`/`serverError` are developer strings
    /// ("Failed to create event."), so they are deliberately NOT shown — the
    /// user gets something actionable instead, and the detail stays in the log.
    var message: String {
        switch self {
        case .invalidData:
            return String(localized: "new-event-error-generic", table: "Events")
        case .unsafeMedia:
            return String(localized: "new-event-error-image-upload", table: "Events")
        case .unknown, .serverError:
            return String(localized: "new-event-error-generic", table: "Events")
        }
    }
}

extension MediaUploadError {
    /// User-facing text for a media failure.
    ///
    /// `.innapropriateContent` is absent on purpose: it is handled before this
    /// by presenting the PostMediaViolation sheet, which explains far more than
    /// an alert line could.
    var message: String {
        switch self {
        case .innapropriateContent, .unexpected:
            return String(localized: "new-event-error-image-upload", table: "Events")
        }
    }
}
