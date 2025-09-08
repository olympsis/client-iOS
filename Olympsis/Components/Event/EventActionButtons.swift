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
    @State private var showRSVPSheet: Bool = false
    @State private var state: LOADING_STATE = .pending
    
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
    
    private var hasRSVP: Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return event.participants.first(where: { $0.user?.uuid == uuid }) != nil
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
    
    @MainActor
    func cancel() {
        guard state != .loading else { return }
        
        Task {
            state = .loading
            
            guard let user = session.user,
                  let uuid = user.uuid else {
                handleFailure()
                return
            }
            
            let resp = await session.eventObserver.removeParticipant(id: event.id)
            guard resp == true else {
                handleFailure()
                return
            }
            
            event.participants.removeAll(where: { $0.user?.uuid == uuid })
            handleSuccess()
        }
    }
    
    @MainActor
    func handleSuccess() {
        state = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    @MainActor
    func handleFailure() {
        state = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    private func leadToMaps(for venue: Venue){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])")! as URL)
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
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
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
                        }.foregroundStyle(Color.foreground)
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
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
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
                        }.foregroundStyle(Color.foreground)
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
                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
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
                        }.foregroundStyle(Color.foreground)
                    }
                }
            }
            
            // MARK: - RSVP/Cancel Buttons
            switch event.getEventStatus() {
            case .pending:
                if !hasRSVP {
                    if let maxPtp = event.participantsConfig?.maxParticipants,
                       let hasWaitlist = event.participantsConfig?.hasWaitlist,
                       hasWaitlist && (event.participants.count >= maxPtp) {
                        Button(action: { showRSVPSheet.toggle() }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(maxWidth: .infinity, idealHeight: 60)
                                    .foregroundColor(Color.Brand.tertiary)

                                VStack {
                                    if state == .loading {
                                        ProgressView()
                                            .frame(width: 30)
                                    } else {
                                        VStack {
                                            Image(systemName: "hourglass.bottomhalf.filled")
                                                .resizable()
                                                .frame(width: 23, height: 17)
                                        }.frame(height: 20)
                                        
                                        Text(String(localized: "status-waitlist", table: "Events"))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                            }.foregroundStyle(.white)
                        }
                    } else {
                        Button(action: { showRSVPSheet.toggle() }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(maxWidth: .infinity, idealHeight: 60)
                                    .foregroundColor(Color.Brand.primary)

                                VStack {
                                    if state == .loading {
                                        ProgressView()
                                            .frame(width: 30)
                                    } else {
                                        VStack {
                                            Image(systemName: "envelope.fill")
                                                .resizable()
                                                .frame(width: 23, height: 17)
                                        }.frame(height: 20)
                                        
                                        Text(String(localized: "status-rsvp", table: "Events"))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                            }.foregroundStyle(.white)
                        }
                        .disabled(state == .loading ? true : false)
                        .disabled(event.getEventStatus() == .ended ? true : false)
                    }
                } else {
                    Button(action: { cancel() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, idealHeight: 60)
                                .foregroundColor(Color.red)

                            VStack {
                                if state == .loading {
                                    ProgressView()
                                        .frame(width: 23)
                                } else {
                                    VStack {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    Text(String(localized: "status-cancel", table: "Events"))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                            }
                        }.foregroundStyle(.white)
                    }
                }
            case .live:
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity, idealHeight: 60)
                    
                    VStack {
                        VStack {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        Text(String(localized: "status-live", table: "Events"))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }.foregroundStyle(.white)
            case .ended:
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, idealHeight: 60)

                    VStack {
                        VStack {
                            Image(systemName: "circle.slash")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        Text(String(localized: "status-ended", table: "Events"))
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }.foregroundStyle(.white)
            }
            
            // MARK: - Menu Button
            Button(action:{ self.showMenu.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 60)
                        .foregroundColor(Color.Background.secondary)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
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
                    }.foregroundStyle(Color.foreground)
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
        .sheet(isPresented: $showRSVPSheet, onDismiss: {
            guard let extLink = event.externalLink,
                  let url = URL(string: extLink), UIApplication.shared.canOpenURL(url) else {
                return
            }
            openURL(url)
        }, content: {
            RSVPSheet(event: event)
                .environment(session)
                .presentationDetents([.height(235)])
        })
    }
}

#Preview {
    EventActionButtons(venues: .constant(VENUES), venueState: .constant(.pending), clubs: .constant(CLUBS), organizations: .constant(ORGANIZATIONS))
        .environment(EVENTS[0])
        .environment(SessionStore())
}
