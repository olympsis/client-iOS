//
//  EventActionButtons.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import SwiftUI

/// A view that contains many of the primary actions that can be taken while viewing an event
struct EventActionButtons: View {
    
    @Binding var event: Event
    @State private var showMenu: Bool = false
    @State private var state: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    private var fieldLocation: [Double] {
        guard let data = event.data,
              let field = data.field else {
            return [0, 0]
        }
        return field.location.coordinates
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
              let uuid = user.uuid,
              let participants = event.participants else {
            return false
        }
        return participants.first(where: { $0.uuid == uuid }) != nil
    }
    
    func rsvp(status: String) async {
        state = .loading
        guard let user = session.user,
              let uuid = user.uuid else {
            handleFailure()
            return
        }
        
        let participant = Participant(id: nil, uuid: uuid, data: nil, status: status, createdAt: nil)
        let resp = await session.eventObserver.addParticipant(id: event.id!, participant)
        
        guard resp == true,
              let id = event.id,
              let update = await session.eventObserver.fetchEvent(id: id) else {
            handleFailure()
            return
        }
        event = update
        handleSuccess()
    }
    
    func cancel() async {
        state = .loading
        guard let id = event.id,
            let user = session.user,
              let uuid = user.uuid,
              let participants = event.participants,
            let participantID = participants.first(where: { $0.uuid == uuid })?.id else {
            handleFailure()
            return
        }
        
        let resp = await session.eventObserver.removeParticipant(id: id, pid: participantID)
        guard resp == true,
            let id = event.id,
            let update = await session.eventObserver.fetchEvent(id: id) else {
            handleFailure()
            return
        }
        event = update
        handleSuccess()
    }
    
    func handleSuccess() {
        state = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    func handleFailure() {
        state = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    private func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(fieldLocation[1]),\(fieldLocation[0])")! as URL)
    }
    
    var body: some View {
        HStack {
            
            // MARK: - Map Button
            Button(action:{ leadToMaps() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("color-prime"))
                    
                    VStack {
                        VStack {
                            Image(systemName: "car.fill")
                                .resizable()
                                .frame(width: 25, height: 20)
                            .imageScale(.large)
                        }.frame(height: 25)
                        Text(event.estimatedTimeToField(session.locationManager.location))
                    }.foregroundColor(.white)
                }
            }
            
            // MARK: - Event Visibility
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(maxWidth: .infinity, idealHeight: 80)
                    .foregroundColor(Color("color-prime"))
                VStack {
                    if event.visibility == "private" {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .frame(width: 20, height: 25)
                            Text("Private")
                        }.foregroundColor(.white)
                    } else {
                        VStack {
                            Image(systemName: "globe")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("Public")
                        }.foregroundColor(.white)
                    }
                }
            }
            
            // MARK: - RSVP/Cancel Buttons
            if !hasRSVP {
                Menu {
                    Button(action: { Task{  await rsvp(status: "maybe") } }) {
                        Text("Maybe")
                    }
                    Button(action:{ Task { await rsvp(status: "yes") } }){
                        Text("I'm In")
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 80)
                            .foregroundColor(Color("color-prime"))
                        VStack {
                            if state == .loading {
                                ProgressView()
                                    .frame(width: 30)
                            } else {
                                VStack {
                                    Image(systemName: "envelope.fill")
                                        .resizable()
                                        .frame(width: 30, height: 20)
                                }.frame(height: 25)
                                Text("RSVP")
                            }
                        }
                    }.foregroundColor(.white)
                }.disabled(state == .loading ? true : false)
                    .disabled(event.stopTime != nil ? true : false)
            } else {
                Button(action: { Task { await cancel() }}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 80)
                            .foregroundColor(Color("color-prime"))
                        VStack {
                            if state == .loading {
                                ProgressView()
                                    .frame(width: 30)
                            } else {
                                VStack {
                                    Image(systemName: "envelope.open")
                                        .resizable()
                                        .frame(width: 30, height: 25)
                                }.frame(height: 25)
                                Text("Cancel")
                            }
                        }
                    }.foregroundColor(.white)
                }
            }
            
            // MARK: - Menu Button
            Button(action:{ self.showMenu.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("color-prime"))
                    VStack {
                        VStack {
                            Image(systemName: "ellipsis")
                                .resizable()
                            .frame(width: 25, height: 5)
                        }.frame(height: 25)
                        Text("More")
                    }.foregroundColor(.white)
                }
            }.sheet(isPresented: $showMenu) {
                EventMenu(event: $event)
                    .presentationDetents([.height(200)])
            }
            
        }.padding(.horizontal)
            .frame(height: 80)
    }
}

#Preview {
    EventActionButtons(event: .constant(EVENTS[0]))
        .environmentObject(SessionStore())
}
