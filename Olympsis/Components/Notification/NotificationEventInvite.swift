//
//  NotificationEventInvite.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/20/26.
//

import SwiftUI

struct NotificationEventInvite: View {
    
    var model: NotificationModel
    private var actor: UserData?

    @State private var event: Event?
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

    /// `Payload` is an enum, so the invite data has to be pattern matched out
    /// of it rather than cast. Invites all share one shape now, so the event id
    /// arrives as the generic `contextID` — which is only an event id because
    /// this view is only used for the event-shaped invite types. Returns `nil`
    /// when this note carries a non-invite payload.
    private var eventID: String? {
        guard case .invite(let data) = model.payload else {
            return nil
        }
        return data.contextID
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
        guard let actor else {
            return Text("olympsis_user ")
        }
        return Text(actor.username + " ")
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
    
    private func declineInvite() {
        
    }
    
    private func acceptInvite() {
        showSheet.toggle()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Header
            HStack(alignment: .top) {
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
                .disabled(loadingStates["note"] == .loading)
                .redacted(reason: loadingStates["note"] == .loading ? [.placeholder] : [])

                BaseLoadingButton(
                    title: primaryActionText,
                    state: loadingState(for: "accept")
                ) { acceptInvite() }
                .disabled(loadingStates["note"] == .loading)
                .redacted(reason: loadingStates["note"] == .loading ? [.placeholder] : [])
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showSheet, content: {
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
            
            loadingStates["note"] = .pending
            guard let e = session.events.first(where: { $0.id == eventID }) else {
                guard let remoteE = await session.eventService.fetchEvent(id: eventID) else {
                    loadingStates["note"] = .failure
                    return
                }
                self.event = remoteE
                loadingStates["note"] = .success
                return
            }
            self.event = e
            loadingStates["note"] = .success
        }
    }
}

#Preview {
    NotificationEventInvite(
        model:
            NotificationModel(
                id: UUID().uuidString,
                type: .eventInvite,
                payload: .invite(
                    .init(
                        contextID: "",
                        requestorID: "",
                        status: .pending
                    )
                ),
                createdAt: Date()
            )
    )
    .environment(SessionStore())
}
