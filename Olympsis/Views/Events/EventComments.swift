//
//  EventCommentsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI

struct EventComments: View {
    
    @State private var text: String = ""
    @State private var state: LOADING_STATE = .pending
    
    @FocusState private var fieldIsFocused: Bool
    
    private var service = EventObserver()
    
    @EnvironmentObject private var event: Event
    @Environment(SessionStore.self) private var session
    
    private var canDelete: Bool {
        return true
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
    
    private func handleFailure() {
        state = .failure
        fieldIsFocused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Comments")
                .font(.title2)
                .bold()
            
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
            
            ForEach(event.comments, id: \.id) { comment in
                EventCommentListItem(comment: comment)
                    .contextMenu {
                        if (canDelete) {
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
    EventComments()
        .environmentObject(EVENTS[0])
        .environment(SessionStore())
}
