//
//  EventActionButtons.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import SwiftUI

/// A view that contains many of the primary actions that can be taken while
/// viewing an event. Laid out as a three-button row — Directions, RSVP, More —
/// each rendered with the shared `FlatButton` pill style.
///
/// The RSVP button (previously a floating call-to-action) lives inline here
/// again. It mirrors the event's current state — RSVP, Going, Maybe, Waitlist,
/// Can't, Live, or Ended — and presents `RSVPSheet` for the interactive states.
/// Informational states (Live / Ended) render as a non-tappable pill.
struct EventActionButtons: View {

    @Binding var venues: [Venue]
    @Binding var venueState: LOADING_STATE

    @Binding var clubs: [Club]
    @Binding var organizations: [Organization]

    @State private var showMenu: Bool = false
    @State private var showRSVPSheet: Bool = false

    @Environment(\.openURL) private var openURL
    @Environment(Event.self) private var event: Event
    @Environment(SessionStore.self) private var session

    private var fieldLocation: [Double] {
        return venues[0].location.coordinates
    }

    private var canCreateEvent: Bool {
        guard let user = session.user,
              let clubs = user.clubs,
              user.sports != nil,       // at least have a sport
              clubs.count > 0,          // at least have a club
              session.clubs.count > 0 else { // data for club has been fetched
            return false
        }
        return true
    }

    /// The current user's RSVP for this event, if any. Derived from the event's
    /// participant list so the button restyles automatically as the user joins
    /// or cancels via the sheet.
    private var rsvp: Participant? {
        guard let user = session.user,
              let userID = user.userID else {
            return nil
        }
        return event.participants.first(where: { $0.user?.userID == userID })
    }

    /// The visual configuration for the RSVP button given the event's current
    /// state.
    ///
    /// - `isActionable` gates whether tapping opens the RSVP sheet; Live / Ended
    ///   are informational only.
    /// - `emphasized` switches the label to the bold-italic face for committed
    ///   states (Going / Maybe / Waitlist / Can't), matching the Figma spec.
    /// - `iconPlacement` floats the icon to the corner for the interactive
    ///   states, but the informational Live / Ended states center their
    ///   indicator above the label instead.
    private var rsvpContent: (title: String, icon: String, tint: Color, isActionable: Bool, emphasized: Bool, iconPlacement: FlatButton.IconPlacement) {
        switch event.getEventStatus() {
        case .pending:
            if let rsvp {
                switch rsvp.status {
                case .Yes:
                    return (String(localized: "status-going", defaultValue: "I'M IN", table: "Events"),
                            "checkmark.circle.fill", Color.Brand.primary, true, true, .topTrailing)
                case .Maybe:
                    return (String(localized: "status-maybe", defaultValue: "MAYBE", table: "Events"),
                            "questionmark.circle.fill", Color.Brand.secondary, true, true, .topTrailing)
                case .Waitlist:
                    return (String(localized: "status-waitlist", table: "Events"),
                            "hourglass.bottomhalf.filled", Color.Brand.tertiary, true, true, .topTrailing)
                case .Cant:
                    return (String(localized: "status-cant", defaultValue: "CAN'T", table: "Events"),
                            "xmark.circle", .gray, true, true, .topTrailing)
                }
            } else {
                return (String(localized: "status-rsvp", table: "Events"),
                        "envelope.fill", Color.Brand.primary, true, false, .topTrailing)
            }
        case .live:
            return (String(localized: "status-live", table: "Events"),
                    "circle.fill", .red, false, true, .stacked)
        case .ended:
            return (String(localized: "status-ended", table: "Events"),
                    "circle.slash", .gray, false, false, .stacked)
        }
    }

    private func leadToMaps(for venue: Venue){
        guard let url = URL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])") else { return }
        UIApplication.shared.open(url)
    }

    var body: some View {
        HStack {

            // MARK: - Directions Button
            // With multiple venues the button becomes a menu so the user can
            // pick which one to navigate to; otherwise it routes to the only
            // venue directly. Both share the `FlatButton` pill.
            if venues.count > 1 {
                Menu {
                    ForEach(venues) { v in
                        Button(action: { leadToMaps(for: v) }) {
                            Text(v.name)
                        }
                    }
                } label: {
                    FlatButton(
                        title: String(localized: "event-action-directions", table: "Events"),
                        systemImage: "arrow.trianglehead.turn.up.right.circle.fill",
                        isRedacted: venueState != .success
                    )
                    .modifier(BackgroundPillModifier())
                }
                .disabled(venueState != .success)
            } else {
                FlatButton(
                    // Show the estimated travel time once venues resolve, else
                    // fall back to a generic "Directions" label.
                    title: venues.first.map { event.estimatedTimeToVenue(venue: $0, LocationManager.shared.location) }
                        ?? String(localized: "event-action-directions", table: "Events"),
                    systemImage: "arrow.trianglehead.turn.up.right.circle.fill",
                    isRedacted: venueState != .success,
                    action: {
                        if let venue = venues.first {
                            leadToMaps(for: venue)
                        }
                    }
                )
                .disabled(venueState != .success)
            }

            // MARK: - RSVP Button
            // A single pill whose look and behavior track `rsvpContent`.
            // Interactive states open `RSVPSheet`; Live / Ended pass no action
            // and therefore render as a plain, non-tappable label.
            let rsvp = rsvpContent
            FlatButton(
                title: rsvp.title,
                systemImage: rsvp.icon,
                background: rsvp.tint,
                foreground: .white,
                emphasized: rsvp.emphasized,
                iconPlacement: rsvp.iconPlacement,
                action: rsvp.isActionable ? { showRSVPSheet.toggle() } : nil
            )
            .sheet(isPresented: $showRSVPSheet) {
                RSVPSheet(event: event)
                    .environment(session)
                    .presentationDetents([.height(325)])
            }

            // MARK: - Menu Button
            FlatButton(
                title: String(localized: "more", table: "General"),
                systemImage: "ellipsis",
                iconSize: CGSize(width: 23, height: 5),
                action: { self.showMenu.toggle() }
            )
            .sheet(isPresented: $showMenu) {
                EventMenu(clubs: $clubs, organizations: $organizations)
                    .environment(event)
                    .presentationDetents([.medium])
            }

        }
        .frame(height: 60)
        .padding(.horizontal)
    }
}

#Preview {
    EventActionButtons(venues: .constant(VENUES), venueState: .constant(.pending), clubs: .constant(CLUBS), organizations: .constant(ORGANIZATIONS))
        .environment(EVENTS[0])
        .environment(SessionStore())
}
