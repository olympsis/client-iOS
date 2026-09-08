//
//  ArchivedNotificationsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/31/26.
//

import SwiftUI

/// The archive: notifications the user swiped away in `NotificationsView`.
///
/// Unlike the bell inbox, these rows are held locally rather than on
/// `SessionStore`. `session.notifications` is the *active* inbox — it drives the
/// unread badge and is fetched unarchived — so archived rows deliberately never
/// touch it. They're fetched fresh each time this screen appears instead of
/// being cached, which is fine for a screen visited this rarely.
struct ArchivedNotificationsView: View {

    @Environment(HomeRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var notifications: [NotificationModel] = []

    /// Starts true so the first paint is a spinner rather than the empty state.
    /// Without it the "nothing archived" copy flashes on every open while the
    /// fetch is still in flight.
    @State private var isLoading: Bool = true

    /// Reloads the archive. Shared by `.task` and `.refreshable`; the spinner is
    /// only meaningful for the former, since pull-to-refresh draws its own.
    private func load(showSpinner: Bool) async {
        if showSpinner {
            isLoading = true
        }
        notifications = await session.archivedNotifications()
        isLoading = false
    }

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                    Spacer()
                }
                .padding(.top, 50)
            } else if notifications.isEmpty {
                // A ScrollView so pull-to-refresh still works with nothing to
                // show — `.refreshable` needs a scrollable container.
                ScrollView {
                    VStack {
                        Text("Nothing archived yet.")
                        HStack {
                            Spacer()
                        }
                    }.padding(.top, 50)
                }
            } else {
                // Same List treatment as the inbox so the two screens are
                // visually identical: no separators, no inset, no system
                // background.
                List {
                    ForEach(notifications, id: \.id) { note in
                        NotificationView(model: note)
                            .environment(session)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.Background.primary)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.Background.primary.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.Foreground.default)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Archived")
            }
        }
        .toolbarRole(.navigationStack)
        // Matches the inbox: swipe from the leading edge to go back.
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.startLocation.x < 40, gesture.translation.width > 100 {
                        router.navigateBack()
                    }
                }
        )
        .refreshable {
            await load(showSpinner: false)
        }
        .task {
            await load(showSpinner: true)
        }
    }
}

#Preview {
    NavigationStack {
        ArchivedNotificationsView()
            .environment(HomeRouter())
            .environment(SessionStore())
    }
}
