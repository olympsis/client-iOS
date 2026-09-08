//
//  NotificationEventReminder.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/26.
//

import SwiftUI

/// Inbox row for an `EVENT_REMINDER` note — "<event> is starting soon".
///
/// Raised by the server's polling service ~30 minutes before an event starts
/// and delivered by notif-service, so unlike the invite row there is no actor
/// and nothing to act on: the whole row is a tap target that opens the event.
struct NotificationEventReminder: View {

    var model: NotificationModel

    /// The event this reminder is about, fetched in `.task`.
    @State private var event: Event?

    @State private var loadingState: LOADING_STATE = .pending

    @Environment(SessionStore.self) private var session

    /// Deep links are routed by `ViewContainer`'s `OpenURLAction`, which turns
    /// an `olympsis://` URL into a real navigation. Using it here means the row
    /// lands in exactly the same place as a tapped push notification, with no
    /// second routing path to keep in sync.
    @Environment(\.openURL) private var openURL

    /// Reminders route by `event_id`, the only id notif-service stamps on them.
    private var eventID: String? {
        model.data.eventID
    }

    /// The event's name for the header.
    ///
    /// Prefers the server's title so the header is right on first paint, and
    /// falls back to the fetched event only if the note arrived without one.
    /// Deliberately NOT `model.displayTitle`: that falls back to the generic
    /// type headline, which would render as "Event reminder is starting soon".
    private var eventName: String? {
        if !model.title.isEmpty {
            return model.title
        }
        return event?.title
    }

    /// "<event> is starting soon", or the generic headline when the note
    /// carries no name to put in front of it.
    private var headerText: Text {
        guard let eventName else {
            return Text(model.type.title)
        }
        return Text(
            String(
                format: String(localized: "notification-event-starting-soon-header", table: "Notifications"),
                eventName
            )
        )
    }

    /// The event card, or a skeleton / error stand-in for it.
    ///
    /// The start time already shows on the card, so the note's localized body
    /// ("Event starts in 30 mins!") is deliberately left out — its minute count
    /// is frozen at send time and would read as stale an hour later.
    @ViewBuilder
    private var noteBody: some View {
        switch loadingState {
        case .success:
            if let event {
                EventSmallListItem(event: event)
            } else {
                EmptyView()
            }
        case .pending, .loading:
            EventSmallListItemPlaceholder()
        case .failure:
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 100)
                .foregroundStyle(Color.Background.secondary)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.border, lineWidth: 1)
                }
                .overlay {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .imageScale(.large)
                            .foregroundColor(.red)
                        Text("Error loading event")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
        }
    }

    /// Opens the event, matching what tapping the push notification does.
    private func openEvent() {
        guard let eventID, let url = URL(string: "olympsis://events?ID=\(eventID)") else {
            return
        }
        openURL(url)
    }

    var body: some View {
        VStack(alignment: .leading) {

            // Header
            HStack(alignment: .center) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color.Foreground.yellow)

                headerText
                    .font(.callout)
                    .fontWeight(model.isRead ? .regular : .bold)
            }

            // Event body
            noteBody
        }
        .padding(.horizontal)
        // The whole row is the tap target, not just the card. contentShape is
        // required: without it the VStack's transparent padding isn't hittable,
        // so taps between the header and the card would fall through.
        .contentShape(Rectangle())
        .onTapGesture { openEvent() }
        // A reminder with no resolvable event has nowhere to go.
        .disabled(eventID == nil)
        .task {
            guard let eventID else {
                loadingState = .failure
                return
            }

            loadingState = .loading

            // Prefer the copy already in the session — the reminder fires for an
            // event the user has RSVP'd to, so it is usually loaded — and only
            // fall back to the network.
            if let e = session.events.first(where: { $0.id == eventID }) {
                self.event = e
                loadingState = .success
            } else if let remoteE = await session.eventService.fetchEvent(id: eventID) {
                self.event = remoteE
                loadingState = .success
            } else {
                loadingState = .failure
            }
        }
    }
}

#Preview {
    NotificationEventReminder(
        model: NotificationModel(
            id: UUID().uuidString,
            title: "Sunday Run",
            type: .eventReminder,
            category: "events",
            data: NotificationData([
                "event_id": "",
                "loc_key": "event-starting-soon"
            ], lists: ["loc_args": ["30"]]),
            createdAt: Date()
        )
    )
    .environment(SessionStore())
}
