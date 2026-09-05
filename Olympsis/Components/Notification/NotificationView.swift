//
//  NotificationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/18/23.
//

import SwiftUI

/// One row in the notification inbox.
///
/// Picks a renderer from the note's type: the invite types get the actionable
/// invite card, reminders get the tappable event card, everything else gets the
/// generic title/body row. Adding a new server type therefore costs nothing
/// here — it decodes to `.unknown` and renders generically until it earns a
/// dedicated view.
struct NotificationView: View {

    var model: NotificationModel

    var body: some View {
        if model.type.isInvite {
            NotificationEventInvite(model: model)
        } else if model.type == .eventReminder {
            NotificationEventReminder(model: model)
        } else {
            NotificationGenericRow(model: model)
        }
    }
}

/// Fallback row for notification types without a bespoke renderer.
///
/// The server sends an empty `body` on purpose — the text is localized
/// on-device from the note's `loc_key`/`loc_args`, which is what
/// `localizedBody` does. Rows whose key isn't in this build's catalogue simply
/// show no body rather than a raw key.
struct NotificationGenericRow: View {

    var model: NotificationModel

    /// Whoever triggered the note, resolved from `actor_id`. Absent for
    /// system-triggered notes (reminders, waitlist promotions), which is why the
    /// avatar is conditional rather than always shown.
    @State private var actor: User?

    @Environment(SessionStore.self) private var session

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Unread marker, so an unread row is scannable without colour alone.
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(model.isRead ? Color.clear : Color.accentColor)
                .padding(.top, 6)

            // Only shown once the actor resolves; system notes have no actor at
            // all, so this stays absent rather than rendering an empty avatar.
            if let actor {
                if let imageURL = actor.imageURL, let url = URL(string: imageURL) {
                    UserBadgeView(size: .small, imageURL: url)
                } else {
                    UserBadgeView(size: .small)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(model.displayTitle)
                    .font(.callout)
                    .fontWeight(model.isRead ? .regular : .bold)

                let body = model.localizedBody
                if !body.isEmpty {
                    Text(body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(model.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .task {
            actor = await session.actor(id: model.data.actorID)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        NotificationView(
            model: NotificationModel(
                id: UUID().uuidString,
                title: "Sunday Run",
                type: .eventComment,
                category: "events",
                data: NotificationData(["event_id": "abc", "loc_key": "event-new-comment"]),
                createdAt: Date()
            )
        )
        NotificationView(
            model: NotificationModel(
                id: UUID().uuidString,
                title: "Morning Ride",
                type: .eventParticipantUpdate,
                category: "events",
                data: NotificationData(["event_id": "abc"]),
                isRead: true,
                createdAt: Date().addingTimeInterval(-3600)
            )
        )
    }
    .environment(SessionStore())
}
