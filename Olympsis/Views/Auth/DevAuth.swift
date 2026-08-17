//
//  DevAuth.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/13/26.
//

import os
import SwiftUI

// MARK: - Model

/// A user that already exists on the local dev server and can be signed in as.
///
/// On DEV builds the backend trusts the `UserID` header instead of a Firebase token
/// (see `AppEnvironment.authHeaders`), so "signing in" is really just picking which ID
/// to put in that header. That's what lets us run N simulators side by side — each one
/// acting as a different user — to exercise group/event features that need more than
/// one person in the room.
struct DevUser: Identifiable, Hashable {

    let username: String
    let userID: String

    var id: String { userID }
}

/// The pool of users `DevAuth` offers.
///
/// These have to be real user documents on whatever host `DEBUG_HOST` points at — the
/// server looks the ID up, it does not create it. Seed a user in the DB, then add a row
/// here. Anything not in this list can still be pasted in at the bottom of the screen.
let DEV_USERS: [DevUser] = [
    DevUser(username: "johndoe", userID: "65cf1a2b3e4f5a6b7c8d9e0f"),
     DevUser(username: "maria_alvarez", userID: "65cf1a2b3e4f5a6b7c8d9e10"),
     DevUser(username: "tnguyen", userID: "65cf1a2b3e4f5a6b7c8d9e11"),
]

// MARK: - Selection Storage

/// Which dev user this particular install is signed in as.
///
/// Backed by `UserDefaults` rather than `Info.plist` because the plist is baked into the
/// bundle — every simulator running the same build would read the exact same ID, which
/// defeats the whole point. `UserDefaults` is per-install, so each simulator holds its own
/// selection and they can act as different people against the same server.
enum DevUserStore {

    private static let key = "dev_user_id"

    /// The ID picked in `DevAuth`, or `nil` when nobody has been picked yet.
    static var selectedUserID: String? {
        guard let id = UserDefaults.standard.string(forKey: key), !id.isEmpty else {
            return nil
        }
        return id
    }

    /// The ID to send in the `UserID` header.
    ///
    /// Falls back to the `DEV_USER_ID` baked into Info.plist so that anything running
    /// before a selection is made still has a usable ID to talk to the server with.
    static var currentUserID: String {
        selectedUserID ?? (Bundle.main.object(forInfoDictionaryKey: "DEV_USER_ID") as? String ?? "")
    }

    static func signIn(_ userID: String) {
        UserDefaults.standard.set(userID, forKey: key)
    }

    static func signOut() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - View

struct DevAuth: View {

    @State private var customUserID: String = ""

    @Environment(SessionStore.self) private var session
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?

    private let cacheService = CacheService()
    private let log = Logger(subsystem: "com.olympsis.client", category: "dev_auth")

    private var trimmedCustomUserID: String {
        customUserID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text("Olympsis Dev")
                    .font(.custom("Archivo-BlackItalic", size: 30, relativeTo: .largeTitle))
                Text(AppEnvironment.current.apiHost)
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal)
            .padding(.top, 30)
            .padding(.bottom, 15)

            // Users
            List {
                Section {
                    ForEach(DEV_USERS) { user in
                        Button {
                            signIn(as: user.userID)
                        } label: {
                            DevUserRow(
                                username: user.username,
                                userID: user.userID,
                                isSelected: DevUserStore.selectedUserID == user.userID
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Escape hatch: sign in as any user in the DB without a rebuild.
                Section("Other") {
                    TextField("user id", text: $customUserID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(.footnote, design: .monospaced))
                        .submitLabel(.go)
                        .onSubmit { signInWithCustomID() }

                    Button("Sign In") {
                        signInWithCustomID()
                    }
                    .disabled(trimmedCustomUserID.isEmpty)
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    /// Points the app at `userID` and drops it into the authenticated state.
    ///
    /// Check-in and notification registration are not kicked off here — `ViewContainer`'s
    /// `.task` block does that once it appears, same as the production Apple sign-in path.
    private func signIn(as userID: String) {
        // Switching users means the cached profile/clubs/events belong to the previous
        // one. Wipe first so the new user doesn't inherit them. Note that clearCache()
        // removes the whole persistent domain, which is why the ID is written and the
        // auth status is set *after* it — otherwise both would be erased.
        if DevUserStore.selectedUserID != userID {
            cacheService.clearCache()
            session.user = nil
        }

        DevUserStore.signIn(userID)
        log.info("Signed in as dev user \(userID).")

        withAnimation {
            authStatus = .authenticated
        }
    }

    private func signInWithCustomID() {
        let id = trimmedCustomUserID
        guard !id.isEmpty else { return }
        signIn(as: id)
    }
}

// MARK: - Row

private struct DevUserRow: View {

    let username: String
    let userID: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .frame(width: 45, height: 45)
                .foregroundStyle(Color.Background.secondary)
                .overlay {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.Foreground.default)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.body)
                    .bold()
                Text(userID)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.Foreground.yellow)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    DevAuth()
        .environment(SessionStore())
}
