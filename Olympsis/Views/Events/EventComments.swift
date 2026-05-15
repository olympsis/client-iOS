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
    /// Optional proxy from the enclosing `EventView` ScrollView. When
    /// supplied, focusing the comment field triggers an explicit
    /// `scrollTo` that pins the *visible* bottom of the input row to
    /// the top of the keyboard. SwiftUI's automatic keyboard avoidance
    /// only aligns the inner `TextField` responder, which means the
    /// outer Capsule decoration (the `.padding(10)` around the
    /// TextField) ends up a few points behind the keyboard. Scrolling
    /// to the HStack's id with `anchor: .bottom` corrects that so the
    /// whole pill + send-button row sits flush above the keyboard.
    var scrollProxy: ScrollViewProxy? = nil

    /// Stable id used as the `scrollTo` target. Lives here as a typed
    /// constant rather than a raw string scattered through the view
    /// body so a rename only happens in one place.
    private let inputRowID = "commentInputRow"

    /// How far above the keyboard the input row should sit once the
    /// focus-driven `scrollTo` runs. Implemented as `.padding(.bottom,
    /// _)` on the scroll target so the anchor calculation in
    /// `scrollTo(anchor: .bottom)` includes the gap automatically.
    /// As a side effect the same gap appears between the input row
    /// and the first comment below it, which reads as natural
    /// separation between the compose field and the list.
    private let inputBottomPadding: CGFloat = 16

    @State private var text: String = ""
    @State private var state: LOADING_STATE = .pending

    @FocusState private var fieldIsFocused: Bool

    private let service = EventObserver()

    @Environment(Event.self) private var event: Event
    @Environment(SessionStore.self) private var session
    
    private var isPosterOrAdmin: Bool {
        
        // check to see if you're the poster
        guard let user = session.user,
           let userID = user.userID else {
            return false
        }
        
        if event.poster?.userID == userID {
            return true
        }
        
        if clubs.first(where: { e in
            e.members.contains { ($0.user?.userID == userID) && ($0.role != MEMBER_ROLES.Member.rawValue) }
        }) != nil {
            return true
        }
        
        
        if organizations.first(where: { e in
            e.members.contains { $0.user?.userID == userID }
        }) != nil {
            return true
        }
        
        return false
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
                
                let snippet = UserSnippet(userID: user.userID,firstName: user.firstName, lastName: user.lastName, imageURL: user.imageURL)
                
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
            switch event.getEventStatus() {
            case .pending, .live:
                Text(String(localized: "event-comments-title", table: "Events"))
                    .font(.title2)
                    .bold()
            case .ended:
                if !event.comments.isEmpty {
                    Text(String(localized: "event-comments-title", table: "Events"))
                        .font(.title2)
                        .bold()
                }
            }
            
            if event.getEventStatus() != .ended {
                HStack {
                    TextField("\(String(localized: "add-a-comment", table: "Events"))...", text: $text)
                        .padding(10)
                        .padding(.horizontal, 5)
                        .focused($fieldIsFocused)
                        .background {
                            Color.Background.secondary
                        }
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                        }
                    
                    Button(action: { addComment() }) {
                        switch state {
                        case .pending, .success:
                            Image(systemName: "paperplane.fill")
                                .padding(10)
                                .background {
                                    Color.Brand.primary
                                }
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                }
                        case .loading:
                            ProgressView()
                                .padding(10)
                                .background {
                                    Color.Brand.primary
                                }
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                }
                        case .failure:
                            Image(systemName: "xmark")
                                .padding(10)
                                .background {
                                    Color.red
                                }
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                }
                        }
                    }
                }
                // Extra bottom padding becomes part of the scroll
                // target's frame because `.id` is applied *after* it.
                // The manual `scrollTo(_, anchor: .bottom)` below
                // aligns this padded bottom with the keyboard top, so
                // the visible HStack ends up `inputBottomPadding`
                // points above the keyboard instead of flush with it
                // — the "bit more padding under it" you asked for.
                .padding(.bottom, inputBottomPadding)
                // Anchor for the manual focus-driven scroll. Tagging
                // the whole HStack (not just the TextField inside)
                // means the *visible* bottom of the row — including
                // the send button, which is the tallest element —
                // is what gets aligned with the keyboard top.
                .id(inputRowID)
                .onChange(of: fieldIsFocused) { _, isFocused in
                    guard isFocused, let proxy = scrollProxy else { return }
                    // The keyboard's present animation runs ~0.25s on
                    // iOS, and we have to scroll *after* the safe-area
                    // inset has been applied — otherwise we'd be
                    // scrolling into the pre-keyboard layout and the
                    // field would end up partially hidden again. The
                    // 0.3s delay gives the system room to settle, then
                    // our `scrollTo` takes over from SwiftUI's
                    // automatic avoidance (which only aligns the inner
                    // TextField responder, leaving the decorative
                    // Capsule + button slightly behind the keyboard).
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(inputRowID, anchor: .bottom)
                        }
                    }
                }
            }
            
            ForEach(event.comments.sorted(by: { eventA, eventB in
                eventA.createdAt > eventB.createdAt
            }), id: \.id) { comment in
                EventCommentListItem(comment: comment)
                    .contextMenu {
                        if (isPosterOrAdmin) {
                            Button(role: .destructive) {
                                deleteComment(comment: comment)
                            } label: {
                                Label(String(localized: "remove-a-comment", table: "Events"), systemImage: "trash.fill")
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
        .environment(EVENTS[0])
        .environment(SessionStore())
}
