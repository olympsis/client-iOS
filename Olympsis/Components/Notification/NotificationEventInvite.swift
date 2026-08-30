//
//  NotificationEventInvite.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/20/26.
//

import SwiftUI

struct NotificationEventInvite: View {
    
    var model: NotificationModel

    /// Whoever sent the invite, resolved in `.task` from the note's `actor_id`.
    ///
    /// This used to be a stored property that nothing ever assigned, so the row
    /// always fell back to the generic avatar and "olympsis_user". The server now
    /// stamps the actor onto every notification, so it can be looked up.
    @State private var actor: User?

    @State private var event: Event?

    /// The invite this note is about, fetched in `.task`.
    ///
    /// notif-service stamps the invite's own id into the note's routing data, so
    /// this is a direct lookup by id. `nil` means there's nothing actionable —
    /// the note predates that routing key, the invite is gone, or it has just
    /// been answered — and both buttons disable.
    @State private var invite: InviteResponse?

    @State private var showSheet: Bool = false
    @State private var loadingStates: [String: LOADING_STATE] = [
        "note": .failure,
        "accept": .pending,
        "decline": .pending
    ]
    @Environment(SessionStore.self) private var session
    
    /// Bridges an entry of `loadingStates` to the `Binding` a `BaseLoadingButton`
    /// expects. Dictionaries can't be projected with `$loadingStates[key]` without
    /// producing an optional binding, so the default is applied here instead.
    private func loadingState(for key: String) -> Binding<LOADING_STATE> {
        Binding(
            get: { loadingStates[key] ?? .pending },
            set: { loadingStates[key] = $0 }
        )
    }

    /// The event this invite points at. Invite notes route by `event_id`; this
    /// view is only used for the event-shaped invite types, so that is the id
    /// that matters here.
    private var eventID: String? {
        model.data.eventID
    }
    
    // The image of the sender of this note
    private var userImage: some View {
        guard let actor, let imageURL = actor.imageURL,
              let url = URL(string: imageURL) else {
            return UserBadgeView(size: .small)
        }
        return UserBadgeView(size: .small, imageURL: url)
    }
    
    // The username of the sender of this note
    private var username: Text {
        guard let name = actor?.username else {
            return Text("olympsis_user ")
        }
        return Text(name + " ")
    }
    
    // The title of the notifcation
    private var headerText: Text {
        switch model.type {
        case .eventInvite:
            return Text("invited you to RSVP to an event!")
        case .teamInvite:
            return Text("invited you to join their team!")
        case .eventCoHost:
            return Text("invited you to Co-Host an event!")
        default:
            return Text("")
        }
    }
    
    // Primary action text depends on the note type
    private var primaryActionText: Text {
        switch model.type {
        case .eventInvite:
            return Text("RSVP")
        case .teamInvite:
            return Text("Join Team")
        case .eventCoHost:
            return Text("Co-Host")
        default:
            return Text("")
        }
    }
    
    @ViewBuilder
    private var noteBody: some View {
        if let event {
            switch loadingStates["note"] {
            case .loading:
                EventSmallListItemPlaceholder()
            case .success:
                EventSmallListItem(event: event)
            case .failure:
                HStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 100)
                        .foregroundStyle(Color.Background.secondary)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.border, lineWidth: 1)
                        }
                        .overlay {
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(.red)
                                    Text("Error loading event")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                }
            case .pending, .none:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
    
    /// Declines the invite. On success `invite` is cleared, which disables both
    /// buttons — the note stays on screen but is no longer actionable.
    private func declineInvite() {
        guard let invite else {
            loadingStates["decline"] = .failure
            return
        }
        Task {
            loadingStates["decline"] = .loading
            let ok = await session.answerInvite(invite, status: .declined)
            loadingStates["decline"] = ok ? .success : .failure
            if ok { self.invite = nil }
        }
    }

    /// Accepts the invite, then opens the RSVP sheet.
    ///
    /// Two calls on purpose: accepting flips the invite to ACCEPTED (which
    /// server-side already registers the user as going), and the sheet then makes
    /// the separate events-API call if they want a different status. The sheet
    /// only opens if the accept succeeded — otherwise they'd be picking an RSVP
    /// for an invite that never got answered.
    private func acceptInvite() {
        guard let invite else {
            loadingStates["accept"] = .failure
            return
        }
        Task {
            loadingStates["accept"] = .loading
            let ok = await session.answerInvite(invite, status: .accepted)
            loadingStates["accept"] = ok ? .success : .failure
            if ok {
                self.invite = nil
                if event != nil { showSheet = true }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Header
            HStack(alignment: .center) {
                userImage
                
                HStack {
                    username
                        .font(.callout)
                        .fontWeight(.bold)
                    +
                    headerText
                        .font(.callout)
                }
            }
            
            // Event body
            noteBody
            
            // Actions
            HStack {
                BaseLoadingButton(
                    title: Text("Decline"),
                    background: Color.Background.secondary,
                    foreground: Color.Foreground.default,
                    state: loadingState(for: "decline")
                ) { declineInvite() }
                .disabled(loadingStates["note"] == .loading || invite == nil)
                .redacted(reason: loadingStates["note"] == .loading ? [.placeholder] : [])

                BaseLoadingButton(
                    title: primaryActionText,
                    state: loadingState(for: "accept")
                ) { acceptInvite() }
                .disabled(loadingStates["note"] == .loading || invite == nil)
                .redacted(reason: loadingStates["note"] == .loading ? [.placeholder] : [])
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showSheet, onDismiss: {
            <#code#>
        }, content: {
            if let event {
                RSVPSheet(event: event)
            }
        })
        .task {
            // Validate event id from the model first
            guard let eventID else {
                loadingStates["note"] = .failure
                return
            }

            // Resolve the invite alongside the event. Kept independent of the
            // event lookup: a failed event fetch should still leave the note
            // actionable, and vice versa.
            //
            // Prefer the invite id the note carries; fall back to matching the
            // user's pending invites by event for notes written before
            // notif-service started stamping invite_id.
            async let fetchedInvite = session.invite(
                id: model.data.inviteID,
                fallbackContextID: eventID
            )

            // Who sent it, so the header can say "<name> invited you…". Purely
            // cosmetic, so a failure just leaves the generic fallback.
            async let fetchedActor = session.actor(id: model.data.actorID)

            loadingStates["note"] = .pending
            if let e = session.events.first(where: { $0.id == eventID }) {
                self.event = e
                loadingStates["note"] = .success
            } else if let remoteE = await session.eventService.fetchEvent(id: eventID) {
                self.event = remoteE
                loadingStates["note"] = .success
            } else {
                loadingStates["note"] = .failure
            }

            self.invite = await fetchedInvite
            self.actor = await fetchedActor
        }
    }
}

#Preview {
    NotificationEventInvite(
        model: NotificationModel(
            id: UUID().uuidString,
            title: "Sunday Run",
            type: .eventInvite,
            category: "invites",
            data: NotificationData([
                "event_id": "",
                "invite_id": "",
                "loc_key": "invite-event"
            ]),
            createdAt: Date()
        )
    )
    .environment(SessionStore())
}
