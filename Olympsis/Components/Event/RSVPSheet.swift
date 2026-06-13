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
    @State private var cantLoadingState: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private let log: Logger = Logger(subsystem: "com.olympsis.client", category: "RSPV_sheet")

    enum Response {
        case yes
        case maybe
    }

    /// The current user's existing RSVP for this event, if any. When present,
    /// selecting a new option cancels this participation first so the new
    /// choice replaces it instead of stacking a second entry.
    private var existingRSVP: Participant? {
        guard let user = session.user,
              let userID = user.userID else {
            return nil
        }
        return event.participants.first(where: { $0.user?.userID == userID })
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
                // If the user already RSVP'd, cancel that participation before
                // registering the new selection. The backend keys participants
                // by user, so without removing the old entry first we'd either
                // create a duplicate or get rejected.
                if let existing = existingRSVP {
                    guard await observer.removeParticipant(id: event.id) else {
                        throw EventError.failedToRemoveParticipant
                    }
                    withAnimation {
                        event.participants.removeAll(where: { $0.id == existing.id })
                    }
                }

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
    
    private func cancel() {
        guard cantLoadingState != .loading else { return }
        
        Task {
            cantLoadingState = .loading
            
            guard let user = session.user,
                  let userID = user.userID else {
                withAnimation(.easeInOut) {
                    cantLoadingState = .failure
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        cantLoadingState = .pending
                    }
                }
                return
            }
            
            let resp = await session.eventObserver.removeParticipant(id: event.id)
            guard resp == true else {
                withAnimation(.easeInOut) {
                    cantLoadingState = .failure
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        cantLoadingState = .pending
                    }
                }
                return
            }
            cantLoadingState = .success
            event.participants.removeAll(where: { $0.user?.userID == userID })
            dismiss()
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 0) {
                // Hide the option the user has already selected — when editing
                // an RSVP they should only see the alternatives they can switch to.
                if existingRSVP?.status != .Yes {
                    Button(action: { handleResponse(.yes) }) {
                        Rectangle()
                            .foregroundStyle(Color.Brand.primary)
                            .overlay {
                                switch inLoadingState {
                                case .loading:
                                    ProgressView()
                                case .pending, .success:
                                    Text(String(localized: "rsvp-yes", table: "Events"))
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
                }

                if existingRSVP?.status != .Maybe {
                    Button(action: { handleResponse(.maybe) }) {
                        Rectangle()
                            .foregroundStyle(Color.Brand.secondary)
                            .overlay {
                                switch maybeLoadingState {
                                case .loading:
                                    ProgressView()
                                case .pending, .success:
                                    Text(String(localized: "rsvp-maybe", table: "Events"))
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

                Button(action: { cancel() }) {
                    Rectangle()
                        .foregroundStyle(Color.gray)
                        .overlay {
                            switch cantLoadingState {
                            case .loading:
                                ProgressView()
                            case .pending, .success:
                                Text(String(localized: "rsvp-cant", table: "Events"))
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
                        Text(String(localized: "rsvp-hide", table: "Events"))
                            .fontWeight(.medium)
                        Text(String(localized: "rsvp-hide-desc", table: "Events"))
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
