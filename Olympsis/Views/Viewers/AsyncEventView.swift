//
//  AsyncEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/3/24.
//

import os
import SwiftUI

struct AsyncEventView: View {

    @State public var eventId: String
    /// Optional section to jump to once the event loads, set when the
    /// view is opened from a tapped push notification.
    var focus: EventFocus? = nil
    @State private var event: Event?
    @State private var state: VIEW_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "async_event_view")
    
    @MainActor
    func fetchEvent() async {
        state = .loading
        guard let event = await session.eventObserver.fetchEvent(id: eventId) else {
            state = .failure
            log.error("Failed to fetch event:\(eventId, privacy: .public)")
            return
        }
        self.event = event
        state = .success
    }
    
    var body: some View {
        Group {
            switch state {
            case .pending, .loading:
                ProgressView()
                    .padding(.vertical, 100)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { Task {
                                await fetchEvent()
                            } }) {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .navigationTitle(String(localized: "event-title", table: "Events"))
                    .navigationBarBackButtonHidden()
                    .navigationBarTitleDisplayMode(.inline)
            case .success:
                if let event {
                    EventView(event: event, focus: focus)
                        .environment(event)
                }
            case .failure:
                VStack {
                    Image("illustrations/sorry")
                        .resizable()
                        .frame(width: 250, height: 250)
                    Text(String(localized: "event-failed-to-load", table: "Events"))
                        .fontWeight(.bold)
                    Button(action: { Task { await fetchEvent() }}) {
                        Text(String(localized: "event-try-again", table: "Events"))
                    }
                }
                .padding(.vertical, 100)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { Task {
                            await fetchEvent()
                        } }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
                .navigationTitle(String(localized: "event-title", table: "Events"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await fetchEvent()
        }
    }
}

#Preview {
    AsyncEventView(eventId: "")
        .environment(SessionStore())
}
