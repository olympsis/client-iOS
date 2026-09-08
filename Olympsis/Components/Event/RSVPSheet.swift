//
//  RSVPSheet.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/25.
//

import os
import SwiftUI

struct RSVPSheet: View {

    var event: Event

    /// Optional hook fired after the sheet successfully changes the user's RSVP:
    /// the newly selected status, or `nil` when the RSVP is retracted.
    var onStatusChange: ((EVENT_RSVP_STATUS?) -> Void)? = nil

    private let observer = EventService()
    @State private var isAnonymous: Bool = false

    /// Per-option loading state, defaulting to `.pending` for any option that
    /// isn't mid-request. Drives the spinner / success / failure feedback in
    /// each `RSVPOption` bar.
    @State private var states: [EVENT_RSVP_STATUS: LOADING_STATE] = [:]

    /// Why the last attempt was refused, shown inline under the options for a
    /// few seconds. Sheets can't use toasts — see `show(_:)`.
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session

    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "RSPV_sheet")

    /// The options offered in the sheet.
    private let options: [EVENT_RSVP_STATUS] = [.Yes, .Maybe]

    /// The current user's existing RSVP for this event, if any. When present,
    /// selecting a new option cancels this participation first so the new
    /// choice replaces it instead of stacking a second entry.
    private var existingRSVP: Participant? {
        guard let user = session.user,
              let userID = user.userID else {
            return nil
        }
        return event.rsvp(for: userID)
    }

    /// The option the user has actively RSVP'd to, derived from the event's
    /// participant list. Because it's computed from `event.participants`, the
    /// selected bar's cancel affordance appears/disappears automatically as we
    /// add or remove the participation below.
    private var selected: EVENT_RSVP_STATUS? {
        existingRSVP?.status
    }

    /// True while any option is mid-request. Used to block a second concurrent
    /// tap while one is in flight.
    private var isBusy: Bool {
        states.values.contains(.loading)
    }

    /// Turns a refusal from the server into something the user can read.
    ///
    /// Matching on the server's own English text is fragile, so the fallback is
    /// deliberately generic rather than showing the raw message — that string is
    /// written for developers and isn't localized.
    private func message(for error: Error) -> String {
        guard case EventError.rejected(let serverMessage) = error else {
            return String(localized: "rsvp-error-generic", defaultValue: "Couldn't update your RSVP. Try again.", table: "Events")
        }

        let text = serverMessage.lowercased()
        if text.contains("event is full") {
            return String(localized: "rsvp-error-full", defaultValue: "This event is full — you're still on the waitlist.", table: "Events")
        }
        if text.contains("team") {
            return String(localized: "rsvp-error-team", defaultValue: "This event takes team RSVPs.", table: "Events")
        }
        return String(localized: "rsvp-error-generic", defaultValue: "Couldn't update your RSVP. Try again.", table: "Events")
    }

    /// Shows the failure inline for a beat. Not a toast: NotificationKit's host
    /// is an overlay underneath any presented sheet, so a toast raised from here
    /// would be invisible.
    @MainActor
    private func show(_ error: Error) async {
        errorMessage = message(for: error)
        try? await Task.sleep(for: .seconds(3))
        errorMessage = nil
    }

    /// Registers (or changes) the user's RSVP with the given status.
    private func select(_ option: EVENT_RSVP_STATUS) {
        guard !isBusy, let user = session.user, let userID = user.userID else { return }

        Task { @MainActor in
            states[option] = .loading
            errorMessage = nil

            let dao = ParticipantDao()
            dao.isAnonymous = isAnonymous
            dao.status = option

            do {
                let response: ParticipantResponse
                if existingRSVP != nil {
                    // Patch rather than delete-then-add: dropping the row frees
                    // the slot, which promotes whoever is next off the waitlist
                    // and leaves the user re-joining behind them.
                    response = try await observer.updateParticipant(id: event.id, dao: dao)
                    if let status = response.status {
                        event.setRSVPStatus(status, for: userID)
                    }
                    // `isAnonymous` rides along on the same call.
                    existingRSVP?.isAnonymous = isAnonymous
                } else {
                    response = try await observer.addParticipant(id: event.id, dao: dao)
                    let snippet = UserSnippet(
                        userID: user.userID,
                        username: user.username,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        imageURL: user.imageURL
                    )
                    // The server's status wins — a full event stores the RSVP as
                    // WAITLIST no matter what was asked for.
                    let participant = Participant(
                        id: response.id,
                        user: snippet,
                        status: response.status ?? option,
                        isAnonymous: isAnonymous,
                        createdAt: Date()
                    )
                    event.insertRSVP(participant)
                }

                await NotificationManager.shared.requestAuthorization()
                await session.updateNotifications()

                // Report the committed choice before the success flash so the
                // caller isn't waiting on the animation to settle.
                onStatusChange?(response.status ?? option)

                // Flash the success state, then settle back to idle. `selected`
                // now reflects this option, so the bar keeps its cancel affordance.
                states[option] = .success
                try? await Task.sleep(for: .seconds(0.8))
                states[option] = .pending
            } catch {
                log.error("Failed to add participant to event. EventID: \(event.id, privacy: .public), Error: \(error)")
                states[option] = .failure
                await show(error)
                states[option] = .pending
            }
        }
    }

    /// Retracts the user's RSVP for the given option.
    private func cancel(_ option: EVENT_RSVP_STATUS) {
        guard !isBusy,
              let user = session.user,
              let userID = user.userID else { return }

        Task { @MainActor in
            states[option] = .loading

            guard await observer.removeParticipant(id: event.id) else {
                states[option] = .failure
                try? await Task.sleep(for: .seconds(2))
                states[option] = .pending
                return
            }

            // Dropping the participation clears `selected`, so the cancel bar
            // slides away on its own. Clears the waitlist array too — a
            // waitlisted user's row lives there, not in `participants`.
            event.removeRSVP(for: userID)
            await session.updateNotifications()
            onStatusChange?(nil)
            states[option] = .pending
        }
    }

    var body: some View {
        VStack(spacing: 15) {
            RSVPOptions(
                options: options,
                selected: selected,
                loadingStates: $states,
                onSelect: select,
                onCancel: cancel
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.opacity)
            }

            HStack {
                Toggle(isOn: $isAnonymous) {
                    VStack(alignment: .leading) {
                        Text(String(localized: "rsvp-hide", table: "Events"))
                            .fontWeight(.medium)
                        Text(String(localized: "rsvp-hide-desc", table: "Events"))
                            .lineLimit(2)
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
                }
            }.padding(.horizontal)

            Spacer()
        }
        .animation(.easeInOut, value: errorMessage)
        .onAppear {
            // Seed the toggle from the row we already have so opening the sheet
            // on an anonymous RSVP doesn't silently un-hide the user on save.
            isAnonymous = existingRSVP?.isAnonymous ?? false
        }
    }
}

#Preview {
    RSVPSheet(event: EVENTS[0])
        .environment(SessionStore())
}
