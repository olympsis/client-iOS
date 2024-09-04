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
    @State private var event: Event?
    @State private var title: String = "Event"
    @State private var state: VIEW_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "async_event_view")
    
    @MainActor
    func fetchEvent() async {
        state = .loading
        guard let event = await session.eventObserver.fetchEvent(id: eventId) else {
            state = .failure
            log.error("Failed to fetch event:\(eventId, privacy: .public)")
            return
        }
        self.title = event.title ?? "Event"
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
                    .navigationTitle(title)
                    .navigationBarBackButtonHidden()
                    .navigationBarTitleDisplayMode(.inline)
            case .success:
                if let event {
                    EventView(event: event)
                }
            case .failure:
                VStack {
                    Image("illustrations/sorry")
                        .resizable()
                        .frame(width: 250, height: 250)
                    Text("Failed to get post.")
                        .fontWeight(.bold)
                    Button(action: { Task { await fetchEvent() }}) {
                        Text("Try again")
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
                .navigationTitle(title)
                .navigationBarBackButtonHidden()
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
        .environmentObject(SessionStore())
}
