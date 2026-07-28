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

    private let observer = EventObserver()
    @State private var isAnonymous: Bool = false

    /// Per-option loading state, defaulting to `.pending` for any option that
    /// isn't mid-request. Drives the spinner / success / failure feedback in
    /// each `RSVPOption` bar.
    @State private var states: [EVENT_RSVP_STATUS: LOADING_STATE] = [:]

    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session

    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "RSPV_sheet")

    /// The options offered in the sheet. "Can't" isn't an option here — declining
    /// simply means no participation, which is expressed by cancelling an existing
    /// RSVP via each bar's cancel affordance.
    private let options: [EVENT_RSVP_STATUS] = [.Yes, .Maybe]

    /// The current user's existing RSVP for this event, if any. When present,
    /// selecting a new option cancels this participation first so the new
    /// choice replaces it instead of stacking a second entry.
    private var existingRSVP: Participant? {
        guard let user = session.user,
              let userID = user.userID else {
            return nil
        }
        return event.participants.first(where: { $0.user?.userID == userID })
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

    /// Registers (or replaces) the user's RSVP with the given status.
    private func select(_ option: EVENT_RSVP_STATUS) {
        guard !isBusy, let user = session.user else { return }

        Task { @MainActor in
            states[option] = .loading

            let dao = ParticipantDao()
            dao.isAnonymous = isAnonymous
            dao.status = option

            do {
                // If the user already RSVP'd, cancel that participation before
                // registering the new selection. The backend keys participants
                // by user, so without removing the old entry first we'd either
                // create a duplicate or get rejected.
                if let existing = existingRSVP {
                    guard await observer.removeParticipant(id: event.id) else {
                        throw EventError.failedToRemoveParticipant
                    }
                    event.participants.removeAll(where: { $0.id == existing.id })
                }

                let id = try await observer.addParticipant(id: event.id, dao: dao)
                let snippet = UserSnippet(
                    userID: user.userID,
                    username: user.username,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    imageURL: user.imageURL
                )
                let participant = Participant(id: id, user: snippet, status: option, isAnonymous: isAnonymous, createdAt: Date())
                event.participants.append(participant)

                await NotificationManager.shared.requestAuthorization()
                await session.updateNotifications()

                // Flash the success state, then settle back to idle. `selected`
                // now reflects this option, so the bar keeps its cancel affordance.
                states[option] = .success
                try? await Task.sleep(for: .seconds(0.8))
                states[option] = .pending
            } catch {
                log.error("Failed to add participant to event. EventID: \(event.id, privacy: .public), Error: \(error)")
                states[option] = .failure
                try? await Task.sleep(for: .seconds(2))
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
            // slides away on its own.
            event.participants.removeAll(where: { $0.user?.userID == userID })
            await session.updateNotifications()
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
    }
}

#Preview {
    RSVPSheet(event: EVENTS[0])
        .environment(SessionStore())
}
