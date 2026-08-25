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

    /// Drives presentation of the floating `EventCommentComposer`.
    /// The composer is hosted up in `EventView` (not here) so it can
    /// ride above the keyboard — see that file's `.overlay` and the
    /// comment on `EventCommentComposer`. Tapping the compose button
    /// in this header flips it on; the composer flips it back off when
    /// the keyboard is dismissed or a comment is submitted.
    @Binding var isComposing: Bool
    @State private var state: LOADING_STATE = .pending

    private let service = EventService()

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
    
    private func deleteComment(comment: EventComment) {
        guard state != .loading else { return }
        
        Task {
            state = .loading
            let isDeleted = await service.removeComment(id: event.id, cid: comment.id)
            if isDeleted {
                event.comments.removeAll(where: { $0.id == comment.id })
                state = .success
            } else {
                state = .failure
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    state = .pending
                }
            }
        }
    }
    
    @ViewBuilder
    private var header: some View {
        HStack {
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
            
            Spacer()
            
            // Hide the comment trigger if the event has ended
            if event.getEventStatus() != .ended {
                // Compose trigger. Instead of an inline text field,
                // this summons the floating `EventCommentComposer`
                // that slides up over the keyboard (mirrors the
                // events-explorer search bar).
                Button(action: { isComposing = true }) {
                    Image(systemName: "square.and.pencil")
                        .padding(10)
                        .background { Color.Brand.primary }
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                        }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            header
            
            ForEach(event.comments.sorted(by: { eventA, eventB in
                eventA.createdAt > eventB.createdAt
            }), id: \.id) { comment in
                EventCommentListItem(comment: comment)
                    // Scroll anchor used by `EventView.scrollToFocus` so a
                    // tapped "New Comment" notification can jump straight
                    // to this comment.
                    .id(comment.id)
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
        }.padding(.horizontal)
    }
}

/// Photos/search-style floating composer that slides up over the
/// keyboard when the user taps the compose button in `EventComments`.
///
/// It deliberately mirrors `FloatingSearchBar` in the events explorer:
/// it owns its own `@FocusState` to summon the keyboard on appear, and
/// because the layer hosting it in `EventView` does NOT opt out of
/// keyboard safe-area avoidance, SwiftUI lifts the whole bar above the
/// keyboard for us. The trailing paperplane button submits the comment
/// and resigns focus; dismissing the keyboard any other way (e.g. an
/// interactive scroll-down) resigns focus too, which tears the bar
/// back down via the `isFocused` observer.
struct EventCommentComposer: View {

    /// Two-way switch shared with `EventComments`/`EventView`. Set to
    /// `false` to dismiss the bar.
    @Binding var isActive: Bool

    @State private var text: String = ""
    @State private var state: LOADING_STATE = .pending

    /// Programmatic focus is what summons the keyboard on appear and,
    /// when set back to `false`, what dismisses it.
    @FocusState private var isFocused: Bool

    private let service = EventService()

    @Environment(Event.self) private var event: Event
    @Environment(SessionStore.self) private var session

    @MainActor
    private func addComment() {
        guard state != .loading, !text.isEmpty else { return }

        Task {
            let dao = EventCommentDao(text: text, eventID: event.id)

            do {
                state = .loading
                let id = try await service.addComment(id: event.id, dao)

                guard let user = session.user else {
                    handleFailure()
                    return
                }

                let snippet = UserSnippet(userID: user.userID, firstName: user.firstName, lastName: user.lastName, imageURL: user.imageURL)

                let comment = EventComment(id: id, user: snippet, text: text, createdAt: Date())
                event.comments.append(comment)
                text = ""
                state = .success
                // Resigning focus dismisses the keyboard; the
                // `isFocused` observer below then tears the bar down.
                isFocused = false
            } catch {
                handleFailure()
            }
        }
    }

    @MainActor
    private func handleFailure() {
        state = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            composePill
            cancelButton
        }
        .onAppear {
            // Small delay so the slide-in transition finishes before
            // the keyboard animation starts — without it the keyboard
            // can summon before the bar is in place, which looks janky.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isFocused = true
            }
        }
        // When focus is lost — submit, interactive scroll-dismiss, etc.
        // — collapse the composer.
        .onChange(of: isFocused) { _, focused in
            guard !focused else { return }
            isActive = false
        }
    }

    /// Capsule containing the comment text field. `maxWidth: .infinity`
    /// lets it absorb the leftover width after the fixed cancel button.
    /// Single-line (no vertical axis) so the keyboard's return key
    /// fires `.onSubmit` to post the comment rather than inserting a
    /// newline.
    @ViewBuilder
    private var composePill: some View {
        let core = TextField(
            String(localized: "add-a-comment", table: "Events"),
            text: $text
        )
        .focused($isFocused)
        .submitLabel(.send)
        .textFieldStyle(.plain)
        .onSubmit { addComment() }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)

        if #available(iOS 26.0, *) {
            core.glassEffect(.regular, in: .capsule)
        } else {
            core.background(.regularMaterial, in: Capsule())
        }
    }

    /// 44×44 glass cancel button. Clears the draft and resigns focus,
    /// which dismisses the keyboard and — via the `isFocused` observer
    /// in `body` — tears the composer down.
    @ViewBuilder
    private var cancelButton: some View {
        let button = Button {
            text = ""
            isFocused = false
            isActive = false
        } label: {
            Image(systemName: "xmark")
                .imageScale(.large)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(Text("Cancel comment"))

        if #available(iOS 26.0, *) {
            button.glassEffect(.regular.interactive(), in: .circle)
        } else {
            button.background(.regularMaterial, in: Circle())
        }
    }
}

#Preview {
    EventComments(clubs: .constant([]), organizations: .constant([]), isComposing: .constant(false))
        .environment(EVENTS[0])
        .environment(SessionStore())
}
