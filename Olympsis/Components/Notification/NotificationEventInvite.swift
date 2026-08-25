//
//  NotificationEventInvite.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/20/26.
//

import SwiftUI

struct NotificationEventInvite: View {
    
    var model: NotificationModel
    private var user: UserData?

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

    // The image of the sender of this note
    private var userImage: some View {
        guard let user, let imageURL = user.imageURL,
              let url = URL(string: imageURL) else {
            return UserBadgeView(size: .small)
        }
        return UserBadgeView(size: .small, imageURL: url)
    }
    
    // The username of the sender of this note
    private var username: Text {
        guard let user else {
            return Text("olympsis_user ")
        }
        return Text(user.username + " ")
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
            }
            
            // Actions
            HStack {
                BaseLoadingButton(
                    title: Text("Decline"),
                    background: Color.Background.secondary,
                    foreground: Color.Foreground.default,
                    state: loadingState(for: "decline")
                ) {}
                    .disabled(loadingStates["note"] == .loading)
                    .redacted(reason: loadingStates["note"] == .loading ? [.placeholder] : [])

                BaseLoadingButton(
                    title: primaryActionText,
                    state: loadingState(for: "accept")
                ) {}
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
            loadingStates["note"] = .pending
            guard let e = session.events.first(where: { $0.id == model.eventID }) else {
                guard let id = model.eventID,
                    let remoteE = await session.eventService.fetchEvent(id: id) else {
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
                orgID: nil,
                clubID: nil,
                eventID: "",
                inviteID: "",
                teamID: nil,
                userID: "",
                body: nil
            )
    )
    .environment(SessionStore())
}
