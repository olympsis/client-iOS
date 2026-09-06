//
//  OutageScreen.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/6/26.
//

import SwiftUI

/// Shown instead of the app when a launch-critical call fails for a reason the
/// user can do something about: no network, or Olympsis itself not answering.
///
/// This exists because those two failures used to be indistinguishable from a
/// signed-out session — an offline launch dropped `authStatus` to
/// `.unauthenticated`, so the user landed on the sign-in screen with the Apple
/// button greyed out (the health check that enables it needs the network too)
/// and no way forward. `FatalScreen` stays for failures we can't classify and
/// can't retry.
struct OutageScreen: View {

    let kind: LAUNCH_OUTAGE

    @Environment(SessionStore.self) private var session

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }

    private var symbol: String {
        switch kind {
        case .offline:
            return "wifi.slash"
        case .serverDown:
            return "exclamationmark.icloud.fill"
        }
    }

    private var title: String {
        switch kind {
        case .offline:
            return String(localized: "outage-offline-title", defaultValue: "You're offline", table: "General")
        case .serverDown:
            return String(localized: "outage-server-title", defaultValue: "Olympsis is unavailable", table: "General")
        }
    }

    private var body_: String {
        switch kind {
        case .offline:
            return String(localized: "outage-offline-body", defaultValue: "Olympsis needs an internet connection. Check yours and try again.", table: "General")
        case .serverDown:
            return String(localized: "outage-server-body", defaultValue: "Our servers aren't responding right now. Please try again in a moment.", table: "General")
        }
    }

    var body: some View {
        // The binding is needed by LoadingButton, which drives its own spinner
        // and check/cross states from the session's retry state.
        @Bindable var session = session

        ZStack {
            Rectangle()
                .ignoresSafeArea(.all)
                .foregroundColor(Color("dark-color"))

            VStack {
                Image("logo/white")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.top, 50)

                Spacer()

                VStack(spacing: 10) {
                    Image(systemName: symbol)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.bottom, 5)

                    Text(title)
                        .foregroundColor(.white)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(body_)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Button(action: { Task { await session.retryAfterOutage() } }) {
                    LoadingButton(
                        text: String(localized: "outage-retry", defaultValue: "Retry", table: "General"),
                        width: 150,
                        height: 50,
                        status: $session.outageRetryState
                    )
                }
                .padding(.top, 30)

                Spacer()

                VStack {
                    Text("Olympsis")
                        .foregroundColor(.white)
                        .bold()
                    Text(appVersion)
                        .foregroundColor(.white)
                        .font(.caption)
                }.padding(.bottom)
            }.frame(maxWidth: .infinity)
        }
    }
}

#Preview("Offline") {
    OutageScreen(kind: .offline)
        .environment(SessionStore())
}

#Preview("Server down") {
    OutageScreen(kind: .serverDown)
        .environment(SessionStore())
}
