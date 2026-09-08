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
    /// this is a direct lookup by id. `nil` means there's nothing actionable — and both buttons disable.
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

    /// The event this invite points at. Invite notes route by `event_id`
    private var eventID: String? {
        model.data.eventID
    }

    /// The current user's participant row on this event, if they hold one.
    ///
    /// Mirrors `RSVPSheet.existingRSVP` so both views agree on what "already
    /// RSVP'd" means. Returns the row rather than a flag because the silent
    /// accept below needs the status the user actually picked.
    private var existingRSVP: Participant? {
        guard let event, let userID = session.user?.userID else { return nil }
        return event.participants.first(where: { $0.user?.userID == userID })
    }

    /// True once the current user holds an RSVP on this event. `Event` is
    /// `@Observable` and `RSVPSheet` appends to `participants` in place, so this
    /// flips the moment they pick a status — no extra state to keep in sync.
    private var hasRSVPd: Bool {
        existingRSVP != nil
    }

    /// Whether both actions are dead: the note is still loading, there is no
    /// actionable invite (missing, or already answered), or the user is already
    /// on the participant list — answering an invite to an event you've RSVP'd
    /// to has nothing left to do.
    private var actionsDisabled: Bool {
        loadingStates["note"] == .loading || invite == nil || hasRSVPd
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

    /// Accepts the invite, optionally carrying the RSVP picked in the sheet.
    ///
    /// Two calls on purpose: the sheet registers the RSVP with the events API,
    /// and this flips the invite to ACCEPTED. The server does its own participant
    /// write when an EVENT invite is accepted, so `response` matters — it tells
    /// the server which status that write should hold. Omit it (team invites, or
    /// an accept with no pick) and the server records a confirmed YES, which is
    /// what this path always did.
    private func acceptInvite(response: EVENT_RSVP_STATUS? = nil) {
        guard let invite else {
            loadingStates["accept"] = .failure
            return
        }
        Task {
            loadingStates["accept"] = .loading
            let ok = await session.answerInvite(invite, status: .accepted, response: response?.asRSVPStatus)
            loadingStates["accept"] = ok ? .success : .failure
            if ok {
                self.invite = nil
            }
        }
    }

    /// Answers an invite the user has effectively already accepted elsewhere.
    ///
    /// If they RSVP'd from the event page instead of this note, the buttons come
    /// up disabled by `hasRSVPd` and nothing would ever answer the invite — it
    /// would sit PENDING forever. This clears it on their behalf.
    ///
    /// The status they actually picked is sent along, and that matters: the
    /// server compares it against the participant row they already hold and,
    /// when the two match, does nothing at all — no duplicate row, no "new
    /// participant" push to the host. Sending no status would instead resolve to
    /// YES on the server and quietly upgrade a Maybe, so `existingRSVP` is a
    /// hard requirement here rather than an optional extra.
    ///
    /// Scoped to `.eventInvite` notes on purpose. `InviteType` has no co-host
    /// case, so a co-host note carries an `.event` invite too — auto-accepting
    /// that would make the user a co-host because they RSVP'd, which is a
    /// different decision and stays a deliberate tap.
    ///
    /// Deliberately silent: the buttons are already dead, so there's no loading
    /// state worth flashing. A failure leaves the invite PENDING to be retried
    /// the next time the note is shown.
    private func acceptAlreadyRSVPdInvite() async {
        guard model.type == .eventInvite,
              let invite, invite.type == .event,
              let status = existingRSVP?.status else { return }

        if await session.answerInvite(invite, status: .accepted, response: status.asRSVPStatus) {
            self.invite = nil
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
                .disabled(actionsDisabled)
                .redacted(reason: loadingStates["note"] == .loading ? [.placeholder] : [])

                BaseLoadingButton(
                    title: primaryActionText,
                    state: loadingState(for: "accept")
                ) {
                    // Event invites collect the RSVP first — the sheet's callback
                    // accepts the invite with whatever the user picks. There is no
                    // RSVP to collect for the other invite types (team membership
                    // IS the RSVP), and no sheet to show if the event failed to
                    // load, so those accept straight away.
                    if invite?.type == .event, event != nil {
                        self.showSheet = true
                    } else {
                        acceptInvite()
                    }
                }
                .disabled(actionsDisabled)
                .redacted(reason: loadingStates["note"] == .loading ? [.placeholder] : [])
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showSheet, content: {
            if let event {
                RSVPSheet(event: event) { status in

                    // Only accept invite on Yes and Maybe callbacks. A retraction
                    // (nil) leaves the invite PENDING, and once it has been
                    // answered there is nothing left to accept — changing the pick
                    // again only updates the RSVP the sheet already wrote.
                    guard let status, status == .Yes || status == .Maybe, invite != nil else { return }

                    // Hand the pick to the invite too: the server uses it as the
                    // status of the participant row the acceptance writes, instead
                    // of defaulting the user to YES.
                    acceptInvite(response: status)
                }
            }
        })
        .task {
            // Validate event id from the model first
            guard let eventID else {
                loadingStates["note"] = .failure
                return
            }

            // Resolve the invite alongside the event.*9
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

            // The user may have RSVP'd from the event page before ever opening
            // this note. In that case both buttons are already disabled, so
            // answer the invite for them instead of leaving it PENDING.
            await acceptAlreadyRSVPdInvite()
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
