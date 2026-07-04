//
//  EventInviteePickerView.swift
//  Olympsis
//
//  Created by Claude on 7/4/26.
//

import SwiftUI

/// A sheet that lets the user search for people (by username) and invite them
/// to a newly created event.
///
/// Behavior mirrors an Instagram-style search: typing debounces for 250ms after
/// the user stops before firing a network request. Selecting a user appends them
/// to the bound `invitees` list, records them in the recently-invited cache, and
/// clears the search bar so the user can immediately search for someone else.
///
/// When the search bar is empty we surface the recently-invited users (capped at
/// 100 by `RecentInviteesCache`), showing the first 10 with a "See more" button
/// to reveal the rest.
struct EventInviteePickerView: View {

    /// The list of selected invitees, owned by `NewEventManager`.
    @Binding var invitees: [UserSnippet]

    @Environment(SessionStore.self) private var session

    /// The current text in the search bar.
    @State private var searchText: String = ""
    /// The users returned by the most recent search, as snippets.
    @State private var results: [UserSnippet] = []
    /// Whether a search request is currently in flight (drives the spinner).
    @State private var isSearching: Bool = false

    /// The recently-invited users, loaded from the cache on appear.
    @State private var recents: [UserSnippet] = []
    /// Whether the full recents list is shown (vs. the first 10).
    @State private var showAllRecents: Bool = false

    /// Number of recents to show before the "See more" button appears.
    private let recentsPreviewLimit = 10

    private let recentCache = RecentInviteesCache()

    /// Debounce interval (in nanoseconds) between the user stopping typing and
    /// the search request firing.
    private let debounceNanoseconds: UInt64 = 250_000_000

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            // No explicit dismiss button — the sheet is dismissed by dragging down.
            Text(String(localized: "invitees-title", table: "Events"))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical)

            // MARK: - Search bar
            searchField
                .padding(.horizontal)

            // MARK: - Content
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                recentsList
            } else {
                searchResultsList
            }

            Spacer()
        }
        .background(Color.Background.primary.ignoresSafeArea())
        .onAppear {
            recents = recentCache.fetch()
        }
        // `.task(id:)` restarts (and cancels the prior run) whenever the search
        // text changes — this is what gives us the debounce + latest-wins search.
        .task(id: searchText) {
            await runSearch()
        }
    }

    // MARK: - Search field
    /// A rounded search field styled to match the venue picker's search bar.
    /// Searching is debounced automatically via `.task(id: searchText)`, so no
    /// explicit submit action is required here.
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(String(localized: "invitee-search-placeholder", table: "Events"), text: $searchText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)

            // Cosmetic microphone to mirror the system search field styling. It is
            // intentionally non-interactive (dictation is available via the keyboard).
            Image(systemName: "mic.fill")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background {
            Capsule()
                .foregroundStyle(Color.Background.secondary)
                .overlay {
                    Capsule().stroke(Color.border)
                }
        }
    }

    // MARK: - Search Results

    @ViewBuilder
    private var searchResultsList: some View {
        if isSearching {
            HStack {
                Spacer()
                ProgressView()
                    .padding(.top, 30)
                Spacer()
            }
        } else if results.isEmpty {
            Text(String(localized: "invitee-no-results", table: "Events"))
                .font(.callout)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 30)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(results, id: \.userID) { user in
                        InviteeRow(user: user, isSelected: isInvited(user)) {
                            selectFromSearch(user)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Recently Invited

    @ViewBuilder
    private var recentsList: some View {
        if recents.isEmpty {
            Text(String(localized: "invitee-search-prompt", table: "Events"))
                .font(.callout)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 30)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(String(localized: "recently-invited-title", table: "Events").uppercased())
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                        .padding(.top, 12)

                    // Only show the first `recentsPreviewLimit` until "See more" is tapped.
                    let visibleRecents = showAllRecents ? recents : Array(recents.prefix(recentsPreviewLimit))
                    ForEach(visibleRecents, id: \.userID) { user in
                        InviteeRow(user: user, isSelected: isInvited(user)) {
                            toggleInvite(user)
                        }
                    }

                    if !showAllRecents && recents.count > recentsPreviewLimit {
                        Button(action: { withAnimation { showAllRecents = true } }) {
                            Text(String(localized: "see-more", table: "General"))
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.Brand.primary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    /// Runs the debounced username search for the current `searchText`.
    ///
    /// Called from `.task(id: searchText)`, so a fresh invocation replaces any
    /// in-flight one whenever the text changes. We sleep for the debounce window
    /// first; if the user keeps typing, this task is cancelled before the request
    /// ever fires.
    private func runSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty query: reset results and bail (recents are shown instead).
        guard !query.isEmpty else {
            results = []
            isSearching = false
            return
        }

        isSearching = true

        // Debounce — wait for typing to settle. If the text changes the task is
        // cancelled and this sleep throws, so we never hit the network.
        try? await Task.sleep(nanoseconds: debounceNanoseconds)
        if Task.isCancelled { return }

        do {
            let users = try await session.userObserver.searchUsers(username: query)
            // Guard against a late response landing after the query moved on.
            if Task.isCancelled { return }
            results = users.map { $0.toSnippet() }
        } catch {
            results = []
        }

        isSearching = false
    }

    /// Selects a user from the search results: adds them (if new), records the
    /// invite, and clears the search bar so the user can search again.
    private func selectFromSearch(_ user: UserSnippet) {
        addInvitee(user)
        // Clearing the text collapses the results and returns focus to a fresh
        // search — the `.task(id:)` restarts and empties `results`.
        searchText = ""
    }

    /// Toggles a user's invited state (used by the recents list).
    private func toggleInvite(_ user: UserSnippet) {
        if isInvited(user) {
            invitees.removeAll { $0.userID == user.userID }
        } else {
            addInvitee(user)
        }
    }

    /// Adds a user to the invitees list (deduped) and records them as recently invited.
    private func addInvitee(_ user: UserSnippet) {
        guard !isInvited(user) else { return }
        invitees.append(user)
        recentCache.record(user)
        recents = recentCache.fetch()
    }

    /// Whether the given user is already in the invitees list.
    private func isInvited(_ user: UserSnippet) -> Bool {
        guard let userID = user.userID else { return false }
        return invitees.contains { $0.userID == userID }
    }
}

/// A single selectable user row used in both the search results and recents lists.
private struct InviteeRow: View {

    let user: UserSnippet
    let isSelected: Bool
    let action: () -> Void

    private var avatarURL: URL? {
        guard let imageURL = user.imageURL else { return nil }
        return generateImageURL(imageURL)
    }

    private var displayName: String {
        switch (user.firstName, user.lastName) {
            case let (f?, l?): return "\(f) \(l)"
            case let (f?, nil): return f
            case let (nil, l?): return l
            default: return user.username ?? "Unknown"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                UserBadgeView(size: .small, imageURL: avatarURL)

                VStack(alignment: .leading) {
                    Text(displayName)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    if let username = user.username {
                        Text("@\(username)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .imageScale(.large)
                    .foregroundStyle(isSelected ? Color.Brand.primary : Color.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            EventInviteePickerView(invitees: .constant([UserSnippet]()))
                .environment(SessionStore())
        }
}
