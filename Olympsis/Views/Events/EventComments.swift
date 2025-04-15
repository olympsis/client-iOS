//
//  EventCommentsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI

struct EventComments: View {
    
    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]
    
    @State private var text: String = ""
    @State private var state: LOADING_STATE = .pending
    
    @FocusState private var fieldIsFocused: Bool
    
    private let service = EventObserver()
    
    @EnvironmentObject private var event: Event
    @Environment(SessionStore.self) private var session
    
    private var isPosterOrAdmin: Bool {
        
        // check to see if you're the poster
        guard let user = session.user,
           let uuid = user.uuid else {
            return false
        }
        
        if event.poster?.uuid == uuid {
            return true
        }
        
        if clubs.first(where: { e in
            e.members.contains { ($0.user?.uuid == uuid) && ($0.role != MEMBER_ROLES.Member.rawValue) }
        }) != nil {
            return true
        }
        
        
        if organizations.first(where: { e in
            e.members.contains { $0.user?.uuid == uuid }
        }) != nil {
            return true
        }
        
        return false
    }
    
    private var eventState: EVENT_STATUS {
        if (event.stopTime < Date()) {
            return EVENT_STATUS.ended
        }
        
        return event.startTime < Date() ? .pending : .live
    }
    
    @MainActor
    private func addComment() {
        guard state != .loading else { return }
        
        Task {
            guard !text.isEmpty else { return }
            let dao = EventCommentDao(text: text, eventID: event.id)
            
            do {
                state = .loading
                let id = try await service.addComment(id: event.id, dao)
                
                guard let user = session.user  else {
                    handleFailure()
                    return
                }
                
                let snippet = UserSnippet(uuid: user.uuid,firstName: user.firstName, lastName: user.lastName, imageURL: user.imageURL)
                
                let comment = EventComment(id: id, user: snippet, text: text, createdAt: Date())
                event.comments.append(comment)
                text = ""
                state = .success
                fieldIsFocused = false
            } catch {
                handleFailure()
            }
        }
    }
    
    @MainActor
    private func deleteComment(comment: EventComment) {
        guard state != .loading else { return }
        
        Task {
            state = .loading
            let isDeleted = await service.removeComment(id: event.id, cid: comment.id)
            if isDeleted {
                event.comments.removeAll(where: { $0.id == comment.id })
                state = .success
            } else {
                handleFailure()
            }
        }
    }
    
    @MainActor
    private func handleFailure() {
        state = .failure
        fieldIsFocused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {            
            switch eventState {
            case .pending, .live:
                Text("Comments")
                    .font(.title2)
                    .bold()
            case .ended:
                if !event.comments.isEmpty {
                    Text("Comments")
                        .font(.title2)
                        .bold()
                }
            }
            
            if eventState != .ended {
                HStack {
                    TextField("Add a comment...", text: $text)
                        .padding(10)
                        .padding(.horizontal, 5)
                        .focused($fieldIsFocused)
                        .background {
                            Color.Background.secondary
                        }
                        .clipShape(Capsule())
                    
                    Button(action: { addComment() }) {
                        switch state {
                        case .pending, .success:
                            Image(systemName: "paperplane.fill")
                                .padding(10)
                                .background {
                                    Color.Brand.primary
                                }
                                .clipShape(Circle())
                        case .loading:
                            ProgressView()
                                .padding(10)
                                .background {
                                    Color.Brand.primary
                                }
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "xmark")
                                .padding(10)
                                .background {
                                    Color.red
                                }
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            ForEach(event.comments, id: \.id) { comment in
                EventCommentListItem(comment: comment)
                    .contextMenu {
                        if (isPosterOrAdmin) {
                            Button(role: .destructive) {
                                deleteComment(comment: comment)
                            } label: {
                                Label("Remove Comment", systemImage: "trash.fill")
                            }
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    EventComments(clubs: .constant([]), organizations: .constant([]))
        .environmentObject(EVENTS[0])
        .environment(SessionStore())
}
