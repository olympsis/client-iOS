//
//  EventActionButtons.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import SwiftUI

/// A view that contains many of the primary actions that can be taken while viewing an event
struct EventActionButtons: View {
    
    @Binding var venues: [Venue]
    @Binding var venueState: LOADING_STATE
    
    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]
    
    @State private var showMenu: Bool = false

    @Environment(\.openURL) private var openURL
    @Environment(Event.self) private var event: Event
    @Environment(SessionStore.self) private var session
    
    private var fieldLocation: [Double] {
        return venues[0].location.coordinates
    }
    
    private var canCreateEvent: Bool {
        guard let user = session.user,
              let clubs = user.clubs,
              user.sports != nil,       // at least have a sport
              clubs.count > 0,          // at least have a club
              session.clubs.count > 0 else { // data for club has been fetched
            return false
        }
        return true
    }
    
//    @MainActor
//    private func rsvp(status: String) {
//        guard state != .loading else { return }
//        
//        Task {
//            guard let user = session.user,
//                  let _ = user.uuid else {
//                handleFailure()
//                return
//            }
//            
//            do {
//                state = .loading
//                let stat = EVENT_RSVP_STATUS(rawValue: status) ?? .Yes
//                let id = try await session.eventObserver.addParticipant(id: event.id, dao: ParticipantDao(status: stat))
//                
//                let snippet = UserSnippet(uuid: user.uuid, username: user.username, firstName: user.firstName, lastName: user.lastName, imageURL: user.imageURL)
//                let participant = Participant(id: id, user: snippet, status: stat, createdAt: Date())
//                event.participants.append(participant)
//                
//                handleSuccess()
//                guard let extLink = event.externalLink,
//                      let url = URL(string: extLink), UIApplication.shared.canOpenURL(url) else {
//                    return
//                }
//                openURL(url)
//            } catch {
//                handleFailure()
//            }
//        }
//    }
    
    private func leadToMaps(for venue: Venue){
        guard let url = URL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])") else { return }
        UIApplication.shared.open(url)
    }
    
    var body: some View {
        HStack {
            
            // MARK: - Map Button
            if venues.count > 1 {
                Menu {
                    ForEach(venues) { v in
                        Button(action: { leadToMaps(for: v) }) {
                            Text(v.name)
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 60)
                            .foregroundColor(Color.Background.secondary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.border, lineWidth: 1)
                            }
                        
                        VStack {
                            VStack {
                                Image(systemName: "arrow.trianglehead.turn.up.right.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            
                            Text(String(localized: "event-action-directions", table: "Events"))
                                .font(.caption)
                                .fontWeight(.bold)
                        }.foregroundStyle(Color.Foreground.default)
                    }.redacted(reason: venueState != .success ? .placeholder : [])
                        .modifier(BackgroundPillModifier())
                }.disabled(venueState != .success ? true : false)

            } else {
                Button(action:{
                    if let venue = venues.first {
                        leadToMaps(for: venue)
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 60)
                            .foregroundColor(Color.Background.secondary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.border, lineWidth: 1)
                            }
                        
                        VStack {
                            VStack {
                                Image(systemName: "arrow.trianglehead.turn.up.right.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                .imageScale(.large)
                            }
                            
                            if let venue = venues.first {
                                Text(event.estimatedTimeToVenue(venue: venue, LocationManager.shared.location))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .redacted(reason: venueState != .success ? .placeholder : [])
                            } else {
                                Text(String(localized: "event-action-directions", table: "Events"))
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }.foregroundStyle(Color.Foreground.default)
                    }
                }.disabled(venueState != .success ? true : false)
            }
            
            // MARK: - Event Visibility
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(maxWidth: .infinity, idealHeight: 60)
                    .foregroundColor(Color.Background.secondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.border, lineWidth: 1)
                    }
                    
                VStack {
                    if event.visibility == EVENT_VISIBILITY_TYPES.Private {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .frame(width: 15, height: 20)
                            Text(String(localized: "visibility-private", table: "Events"))
                                .font(.caption)
                                .fontWeight(.bold)
                        }.foregroundColor(.white)
                    } else {
                        VStack {
                            Image(systemName: "globe")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text(String(localized: "visibility-public", table: "Events"))
                                .font(.caption)
                                .fontWeight(.bold)
                        }.foregroundStyle(Color.Foreground.default)
                    }
                }
            }
            
            // MARK: - Menu Button
            Button(action:{ self.showMenu.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 60)
                        .foregroundColor(Color.Background.secondary)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.border, lineWidth: 1)
                        }
                    VStack {
                        VStack {
                            Image(systemName: "ellipsis")
                                .resizable()
                            .frame(width: 23, height: 5)
                        }.frame(height: 20)
                        Text(String(localized: "more", table: "General"))
                            .font(.caption)
                            .fontWeight(.bold)
                    }.foregroundStyle(Color.Foreground.default)
                }
            }
            .sheet(isPresented: $showMenu) {
                EventMenu(clubs: $clubs, organizations: $organizations)
                    .environment(event)
                    .presentationDetents([.medium])
            }
            
        }
        .frame(height: 60)
        .padding(.horizontal)
    }
}

#Preview {
    EventActionButtons(venues: .constant(VENUES), venueState: .constant(.pending), clubs: .constant(CLUBS), organizations: .constant(ORGANIZATIONS))
        .environment(EVENTS[0])
        .environment(SessionStore())
}
