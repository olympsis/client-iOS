//
//  InAppNotificationPreviews.swift
//  NotificationKit
//
//  Sample notifications + an interactive demo screen. DEBUG-only; ships
//  nothing in release builds.
//

#if DEBUG
import SwiftUI

// MARK: - Sample data

public extension InAppNotification {
    static var sampleShort: InAppNotification {
        InAppNotification(
            title: "Event starting soon",
            leadingImage: .system("calendar", tint: .orange)
        )
    }

    static var sampleWithAvatar: InAppNotification {
        InAppNotification(
            title: "**Jane Miller** joined your event",
            subtitle: "Sunday Pickup · 6:00 PM",
            leadingImage: .remote(URL(string: "https://i.pravatar.cc/150?img=47")!),
            coalesceID: "sample-join"
        )
    }

    static var sampleTwoLine: InAppNotification {
        InAppNotification(
            title: "**Marcus** commented",
            subtitle: "\"Are we still on if it rains? I can bring a canopy and some extra water for everyone just in case it gets bad.\"",
            leadingImage: .remote(URL(string: "https://i.pravatar.cc/150?img=12")!),
            trailingImage: .remote(URL(string: "https://picsum.photos/seed/event/200")!)
        )
    }

    static var sampleBrokenImage: InAppNotification {
        InAppNotification(
            title: "Broken image fallback",
            subtitle: "The avatar URL 404s — symbol shows instead",
            leadingImage: .remote(URL(string: "https://example.invalid/nope.png")!)
        )
    }

    static var samplePersistent: InAppNotification {
        InAppNotification(
            title: "**Heads up** — this one stays",
            subtitle: "isDismissible = false, duration = 30s. Tap to dismiss.",
            leadingImage: .system("pin.fill", tint: .red),
            duration: 30,
            isDismissible: false
        )
    }
}

// MARK: - Interactive demo

/// Exercises the *host*, not just the card: fire toasts over scrollable
/// content and try the drag, flick, tap, and queue behavior. Reachable from
/// a DEBUG-only entry point in the app, and from the "Host — interactive"
/// preview below.
public struct InAppNotificationDemoView: View {
    private let presenter = InAppNotificationPresenter.shared

    public init() {}

    public var body: some View {
        List {
            Section("Fire one") {
                Button("Short (title only)") { presenter.present(.sampleShort) }
                Button("Avatar + bold title") { presenter.present(.sampleWithAvatar) }
                Button("Two-line + trailing image") { presenter.present(.sampleTwoLine) }
                Button("Broken image URL") { presenter.present(.sampleBrokenImage) }
                Button("Persistent (no swipe dismiss)") { presenter.present(.samplePersistent) }
            }

            Section("Queue behavior") {
                Button("Burst of 3 (queued)") {
                    presenter.present(.sampleShort)
                    presenter.present(.sampleWithAvatar)
                    presenter.present(.sampleTwoLine)
                }
                Button("Burst of 3 identical (coalesced to 1 pending)") {
                    presenter.present(.sampleWithAvatar)
                    presenter.present(.sampleWithAvatar)
                    presenter.present(.sampleWithAvatar)
                }
            }

            Section("With tap action") {
                Button("Tap prints to console") {
                    presenter.present(InAppNotification(
                        title: "**Tap me**",
                        subtitle: "Runs the onTap closure, then dismisses",
                        leadingImage: .system("hand.tap.fill", tint: .blue),
                        onTap: { print("[NotificationKit demo] toast tapped") }
                    ))
                }
            }

            Section("Manual checklist") {
                Text(
                    """
                    • Drag down → rubber-bands, snaps back, timer resumes
                    • Drag up past 40pt → dismisses
                    • Short fast flick up → dismisses (velocity)
                    • Hold the card → never auto-dismisses
                    • Tap → action fires + dismisses
                    • Tap outside the card → passes through
                    """
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("NotificationKit Demo")
    }
}

// MARK: - Previews

#Preview("Card — variants") {
    VStack(spacing: 16) {
        InAppNotificationCard(notification: .sampleShort)
        InAppNotificationCard(notification: .sampleWithAvatar)
        InAppNotificationCard(notification: .sampleTwoLine)
        InAppNotificationCard(notification: .sampleBrokenImage)
    }
    .padding()
}

#Preview("Card — dark") {
    VStack(spacing: 16) {
        InAppNotificationCard(notification: .sampleWithAvatar)
        InAppNotificationCard(notification: .sampleTwoLine)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Card — XXL type") {
    InAppNotificationCard(notification: .sampleTwoLine)
        .padding()
        .dynamicTypeSize(.accessibility2)
}

#Preview("Host — interactive") {
    NavigationStack {
        InAppNotificationDemoView()
    }
    .inAppNotifications()
}
#endif
