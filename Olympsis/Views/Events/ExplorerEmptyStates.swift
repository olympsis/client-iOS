//
//  ExplorerEmptyStates.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/13/26.
//

import SwiftUI

/// Shared layout for the explorer's empty states.
///
/// Centers an illustration, a bold title, a supporting subtitle and an
/// optional call-to-action button. The two concrete empty states below
/// (`EventsEmptyState` / `VenuesEmptyState`) feed it their own copy and
/// action so the framing stays identical between the events and venues
/// pages.
private struct ExplorerEmptyStateLayout<Action: View>: View {

    let illustration: String
    let title: String
    let subtitle: String
    /// Trailing action (button) rendered under the subtitle. Pass an
    /// `EmptyView` when there's nothing to offer.
    @ViewBuilder var action: Action

    var body: some View {
        VStack {
            Image(illustration)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 130)
                .padding(.top)

            Text(title)
                .font(.body)
                .fontWeight(.bold)
                .padding(.top)
                .padding(.bottom, 5)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.callout)
                .padding(.bottom)
                .padding(.horizontal)
                .multilineTextAlignment(.center)

            action
                .padding(.top, 4)
        }
        .padding(.top, 50)
        .padding(.horizontal)
    }
}

/// Empty state for the events page when there are no events nearby.
///
/// This is the friendly counterpart to the old "failed to load" view — it's
/// what the user should see on a `204 No Content` (or otherwise empty)
/// response rather than an error. It nudges them to start the first event.
///
/// `onCreate` is optional so the button only appears when the host can
/// actually route to event creation (the list is sometimes shown inside a
/// sheet without a router).
struct EventsEmptyState: View {

    var onCreate: (() -> Void)? = nil

    var body: some View {
        ExplorerEmptyStateLayout(
            illustration: "illustrations/goals",
            title: String(localized: "no-events-title", table: "Events"),
            subtitle: String(localized: "no-events-sub-title", table: "Events")
        ) {
            if let onCreate {
                Button(action: onCreate) {
                    SimpleButtonLabel(text: String(localized: "empty-events-button", table: "Events"))
                }
            }
        }
    }
}

/// Empty state for the venues page when there are no venues nearby.
///
/// Venues are curated by us rather than user-created, so instead of asking
/// the user to add one we encourage them to email us and we'll get their
/// area covered. The button opens the system mail composer pre-addressed to
/// contact@olympsis.com via the `openURL` environment action.
struct VenuesEmptyState: View {

    @Environment(\.openURL) private var openURL

    /// Pre-addressed `mailto:` link. Built with `URLComponents` so the
    /// subject is percent-encoded correctly; this resolves to
    /// `mailto:contact@olympsis.com?subject=...` and opens the Mail app.
    private var mailURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "contact@olympsis.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Add venues in my area")
        ]
        return components.url
    }

    var body: some View {
        ExplorerEmptyStateLayout(
            illustration: "illustrations/world",
            title: String(localized: "no-venues-contact-title", table: "Events"),
            subtitle: String(localized: "no-venues-contact-sub-title", table: "Events")
        ) {
            Button {
                if let mailURL {
                    openURL(mailURL)
                }
            } label: {
                SimpleButtonLabel(text: String(localized: "empty-venues-button", table: "Events"))
            }
        }
    }
}

/// Generic failure state for the explorer.
///
/// Shown whenever a fetch returns something other than a usable `200`
/// response (network error, server error, decode failure, etc.). Rather
/// than tailoring copy per resource, it carries one generic message plus a
/// "Try Again" button. The `retry` closure is supplied by the host so the
/// same view drives the events and venues pages — the view model decides
/// which resource(s) actually get re-fetched.
struct ExplorerErrorState: View {

    let retry: () -> Void

    var body: some View {
        ExplorerEmptyStateLayout(
            illustration: "illustrations/error",
            title: String(localized: "explorer-error-title", table: "Events"),
            subtitle: String(localized: "explorer-error-sub-title", table: "Events")
        ) {
            Button(action: retry) {
                SimpleButtonLabel(text: String(localized: "explorer-error-button", table: "Events"))
            }
        }
    }
}

#Preview("Events") {
    EventsEmptyState(onCreate: {})
}

#Preview("Venues") {
    VenuesEmptyState()
}

#Preview("Error") {
    ExplorerErrorState(retry: {})
}
