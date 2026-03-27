//
//  RSVPSheet.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/25.
//

import os
import SwiftUI

struct RSVPSheet: View {

    var event: Event
    
    private let observer = EventObserver()
    @State private var isAnonymous: Bool = false
    @State private var inLoadingState: LOADING_STATE = .pending
    @State private var maybeLoadingState: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "RSPV_sheet")
    
    enum Response {
        case yes
        case maybe
    }
    
    private func handleResponse(_ response: Response) {
        guard inLoadingState != .loading,
              maybeLoadingState != .loading,
              let user = session.user else { return }
        
        Task { @MainActor in
            let dao = ParticipantDao()
            dao.isAnonymous = isAnonymous
            
            switch response {
            case .yes:
                withAnimation(.easeInOut) {
                    inLoadingState = .loading
                    dao.status = .Yes
                }
            case .maybe:
                withAnimation(.easeInOut) {
                    maybeLoadingState = .loading
                    dao.status = .Maybe
                }
            }
            
            do {
                let id = try await observer.addParticipant(id: event.id, dao: dao)
                let snippet = UserSnippet(
                    userID: user.userID,
                    username: user.username,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    imageURL: user.imageURL
                )
                let participant = Participant(id: id, user: snippet, status: response == .yes ? .Yes : .Maybe, isAnonymous: isAnonymous, createdAt: Date())
                
                withAnimation {
                    event.participants.append(participant)
                }
                
                await NotificationManager.shared.requestAuthorization()
                await session.updateNotifications()
                
                dismiss()
            } catch {
                log.error("Failed to add participant to event. EventID: \(event.id, privacy: .public), Error: \(error)")
                switch response {
                case .yes:
                    withAnimation(.easeInOut) {
                        inLoadingState = .failure
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            inLoadingState = .pending
                        }
                    }
                case .maybe:
                    withAnimation(.easeInOut) {
                        maybeLoadingState = .failure
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            maybeLoadingState = .pending
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 0) {
                Button(action: { handleResponse(.yes) }) {
                    Rectangle()
                        .foregroundStyle(Color.Brand.primary)
                        .overlay {
                            switch inLoadingState {
                            case .loading:
                                ProgressView()
                            case .pending, .success:
                                Text("I'm in!")
                                    .textCase(.uppercase)
                                    .foregroundStyle(.white)
                                    .font(.custom("Archivo-BlackItalic", size: 30, relativeTo: .largeTitle))
                            case .failure:
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.yellow)
                            }
                        }
                }
                .frame(height: 80)
                .disabled(maybeLoadingState == .loading)
                .opacity(maybeLoadingState == .loading ? 0.5 : 1)
                
                Button(action: { handleResponse(.maybe) }) {
                    Rectangle()
                        .foregroundStyle(Color.Brand.secondary)
                        .overlay {
                            switch maybeLoadingState {
                            case .loading:
                                ProgressView()
                            case .pending, .success:
                                Text("Maybe")
                                    .textCase(.uppercase)
                                    .foregroundStyle(.white)
                                    .font(.custom("Archivo-BlackItalic", size: 30, relativeTo: .largeTitle))
                            case .failure:
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.yellow)
                            }
                        }
                }
                .frame(height: 80)
                .disabled(inLoadingState == .loading)
                .opacity(inLoadingState == .loading ? 0.5 : 1)
            }
            
            HStack {
                Toggle(isOn: $isAnonymous) {
                    VStack(alignment: .leading) {
                        Text("Hide my RSVP")
                            .fontWeight(.medium)
                        Text("Keep your attendance private from others.")
                            .lineLimit(2)
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
                }
            }.padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    RSVPSheet(event: EVENTS[0])
        .environment(SessionStore())
}

