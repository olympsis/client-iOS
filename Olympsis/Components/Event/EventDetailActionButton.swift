//
//  EventDetailTopActionButtons.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailActionButton: View {
    
    @Binding var event: Event
    @Binding var showMenu: Bool
    @State private var state: LOADING_STATE = .pending
    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var session:SessionStore
    
    func startEvent() async {
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualStartTime: now)
        state = .loading
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.updateEvent(id: id, dao: dao)
        if res {
            await MainActor.run {
                withAnimation(.easeInOut){
                    event.actualStartTime = now
                    state = .success
                }
            }
        }
    }
    
    func stopEvent() async {
        let now = Int(Date.now.timeIntervalSince1970)
        let dao = EventDao(actualStopTime: now)
        state = .loading
        guard let id = event.id else {
            return
        }
        let res = await session.eventObserver.updateEvent(id: id, dao: dao)
        if res {
            await MainActor.run {
                withAnimation(.easeInOut){
                    event.stopTime = now
                    state = .success
                }
            }
        }
    }
    
    var body: some View {
        HStack {
            if event.actualStartTime == nil {
                Button(action:{ Task { await startEvent() } }){
                    ZStack {
                        Image(systemName: "play.fill")
                            .imageScale(.large)
                            .foregroundColor(.green)
                        .frame(width: 40, height: 40)
                        if state == .loading {
                            ProgressView()
                        }
                    }
                }.disabled(state == .loading ? true : false)
            } else if event.actualStartTime != nil {
                Button(action:{ Task { await stopEvent() } }){
                    ZStack {
                        Image(systemName: "stop.fill")
                            .imageScale(.large)
                            .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        if state == .loading {
                            ProgressView()
                        }
                    }
                }.disabled(state == .loading ? true : false)
            }
        }
    }
}

#Preview {
    EventDetailActionButton(event: .constant(EVENTS[0]), showMenu: .constant(false))
}
