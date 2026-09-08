//
//  NewEventInvitees.swift
//  Olympsis
//
//  Created by Claude on 7/4/26.
//

import SwiftUI

/// The "Invitees" card shown while creating a new event. It lists the users
/// currently selected to be invited and offers an "Add an Invitee" button that
/// opens `EventInviteePickerView` for searching and selecting people.
///
/// Selected invitees are stored on `NewEventManager.invitees` as `UserSnippet`s
/// (for display); the manager maps them to user IDs when building the DTO.
struct NewEventInvitees: View {

    @State var manager: NewEventManager

    @State private var showInviteePicker: Bool = false

    @Environment(SessionStore.self) private var session

    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "invitees-title", table: "Events").uppercased())
                .font(.caption)
                .bold()

            VStack(spacing: 0) {
                // MARK: - Selected invitees
                ForEach(Array(manager.invitees.enumerated()), id: \.element.userID) { index, invitee in
                    InviteeListRow(invitee: invitee) {
                        manager.invitees.removeAll { $0.userID == invitee.userID }
                    }

                    // Divider between rows (not after the last one).
                    if index < manager.invitees.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }

                // A divider separates the list from the add button when there
                // are already invitees above it.
                if !manager.invitees.isEmpty {
                    Divider()
                }

                // MARK: - Add an invitee
                Button(action: { showInviteePicker = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                        Text(String(localized: "add-an-invitee", table: "Events"))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .contentShape(Rectangle())
                    .background(Color.Background.secondary)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 26)
                    .foregroundStyle(Color.Background.secondary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.border)
            }
        }
        .sheet(isPresented: $showInviteePicker) {
            EventInviteePickerView(invitees: $manager.invitees)
                .environment(session)
        }
    }
}

/// A single selected-invitee row inside the invitees card, with a trailing
/// remove button.
private struct InviteeListRow: View {

    let invitee: UserSnippet
    let onRemove: () -> Void

    private var avatarURL: URL? {
        guard let imageURL = invitee.imageURL else { return nil }
        return generateImageURL(imageURL)
    }

    private var displayName: String {
        switch (invitee.firstName, invitee.lastName) {
            case let (f?, l?): return "\(f) \(l)"
            case let (f?, nil): return f
            case let (nil, l?): return l
            default: return invitee.username ?? "Unknown"
        }
    }

    var body: some View {
        HStack {
            UserBadgeView(size: .small, imageURL: avatarURL)

            Text(displayName)
                .font(.callout)
                .fontWeight(.bold)
                .padding(.leading, 4)

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    NewEventInvitees(manager: NewEventManager())
        .environment(SessionStore())
        .padding()
}
