//
//  EventRSVPButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/13/26.
//

import SwiftUI

/// A floating call-to-action that hovers above the toolbar at the bottom of
/// the event screen. It mirrors the event's current state — RSVP, Waitlist,
/// Edit RSVP (when the user has already joined), Live, or Ended — and presents
/// `RSVPSheet` for the interactive states.
///
/// Visually it uses Liquid Glass on iOS 26+ and falls back to a frosted
/// material capsule on older systems. The availability branch lives in
/// `RSVPButtonGlassBackground` to keep the button body readable.
struct EventRSVPButton: View {

    var event: Event
    @State private var showRSVPSheet: Bool = false
    @Environment(SessionStore.self) private var session

    private var rsvp: Participant? {
        guard let user = session.user,
              let userID = user.userID else {
            return nil
        }
        return event.participants.first(where: { $0.user?.userID == userID })
    }

    /// The visual configuration for the button given the event's current state.
    /// `isActionable` controls whether tapping presents the RSVP sheet —
    /// informational states (Live / Ended) are non-interactive.
    private var content: (title: String, icon: String, tint: Color, isActionable: Bool) {
        switch event.getEventStatus() {
        case .pending:
            if let rsvp {
                switch rsvp.status {
                case .Waitlist:
                    return (String(localized: "status-waitlist", table: "Events"),
                            "hourglass.bottomhalf.filled", Color.Brand.tertiary, true)
                case .Maybe:
                    return (String(localized: "status-maybe", defaultValue: "MAYBE", table: "Events"),
                            "square.and.pencil", Color.Brand.secondary, true)
                case .Yes:
                    return (String(localized: "status-going", defaultValue: "I'M IN", table: "Events"),
                            "square.and.pencil", Color.Brand.primary, true)
                case .Cant:
                    // No dedicated decline color exists here, so reuse the same
                    // tertiary tint as .Waitlist (per the fallback) with an
                    // xmark to read as a decline. Still actionable so the user
                    // can re-open the sheet and switch their answer.
                    return (String(localized: "status-cant", defaultValue: "CAN'T", table: "Events"),
                            "xmark.circle", Color.Brand.tertiary, true)
                }
            } else {
                return (String(localized: "status-rsvp", table: "Events"),
                        "envelope.fill", Color.Brand.primary, true)
            }
        case .live:
            return (String(localized: "status-live", table: "Events"),
                    "circle.fill", Color.red, false)
        case .ended:
            return (String(localized: "status-ended", table: "Events"),
                    "circle.slash", Color.gray, false)
        }
    }

    var body: some View {
        let config = content

        Button(action: {
            guard config.isActionable else { return }
            showRSVPSheet.toggle()
        }) {
            Group {
                switch event.getEventStatus() {
                case .pending:
                    VStack {
                        Image(systemName: config.icon)
                            .imageScale(.medium)
                        Text(config.title)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                case .ended:
                    VStack {
                        Image(systemName: config.icon)
                            .imageScale(.medium)
                        Text(config.title)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                default:
                    VStack(spacing: 5) {
                        Image(systemName: "square.and.pencil")
                        Text("Edit RSVP")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
            .foregroundStyle(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 15)
            .modifier(RSVPButtonGlassBackground(tint: config.tint, isActionable: config.isActionable))
        }
        .buttonStyle(.plain)
        .disabled(!config.isActionable)
        .padding(.horizontal)
        .sheet(isPresented: $showRSVPSheet) {
            RSVPSheet(event: event)
                .environment(session)
                .presentationDetents([.height(325)])
        }
    }
}

/// Applies a Liquid Glass capsule background on iOS 26+, falling back to a
/// frosted material capsule on older systems. Kept as a `ViewModifier` so the
/// availability branch stays out of the button's view body.
private struct RSVPButtonGlassBackground: ViewModifier {
    let tint: Color
    let isActionable: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    isActionable
                        ? .regular.tint(tint.opacity(0.85)).interactive()
                        : .regular.tint(tint.opacity(0.85)),
                    in: RoundedRectangle(cornerRadius: 20)
                )
        } else {
            content
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .overlay {
                            Capsule().fill(tint.opacity(0.55))
                        }
                        .overlay {
                            Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1)
                        }
                }
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        }
    }
}

#Preview {
    EventRSVPButton(event: EVENTS[0])
        .environment(SessionStore())
}
