//
//  VenueDetails.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/15/26.
//

import SwiftUI

struct VenueDetails: View {
    var venue: Venue

    // MARK: - Pill model
    //
    // Mirrors the `Pill` shape from the web client. `kind` is kept so we
    // can later style each variant differently (color / icon) without
    // restructuring the view; today it only drives the SF Symbol.
    private struct VenuePill: Identifiable {
        enum Kind {
            case surface, paid, indoor, outdoor, lights, accessible,
                 permit, noPermit, membership, booking
        }
        let id = UUID()
        let label: String
        let kind: Kind
    }

    /// Most-common surface in a given slice of units. Pulled out so both
    /// the pill strip (which uses the whole venue) and the per-sport court
    /// sections (which use a single group) share the same tally logic.
    private func dominantSurface(of units: [VenueUnit]) -> String? {
        let surfaces = units
            .map { $0.surface }
            .filter { !$0.isEmpty }
        guard !surfaces.isEmpty else { return nil }
        let counts = Dictionary(surfaces.map { ($0, 1) }, uniquingKeysWith: +)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    /// Venue-wide dominant surface — drives the surface pill.
    private var dominantSurface: String? { dominantSurface(of: venue.units) }

    /// Units grouped by their primary (first-listed) sport. We iterate
    /// `venue.sports` rather than the dictionary keys so the on-screen
    /// order is stable across renders and matches the venue's declared
    /// sport order. Units with no sport are skipped — there's nothing
    /// meaningful to label them with.
    private var courtsBySport: [(sport: String, units: [VenueUnit])] {
        let grouped = Dictionary(grouping: venue.units) { $0.sports.first ?? "" }
        return venue.sports.compactMap { sport in
            guard let units = grouped[sport], !units.isEmpty else { return nil }
            return (sport, units)
        }
    }

    /// True when any unit advertises a rate — drives the "Paid" pill.
    private var hasRates: Bool {
        venue.units.contains { !$0.rates.isEmpty }
    }

    /// Convert wire-format surface values like `"natural_grass"` into the
    /// display form `"Natural Grass"`.
    private func titleize(_ raw: String) -> String {
        raw.replacingOccurrences(of: "_", with: " ").capitalized
    }

    /// Ordered list of pills to render. Order matches the web client so
    /// the two surfaces stay visually consistent.
    private var pills: [VenuePill] {
        var out: [VenuePill] = []

        if let surface = dominantSurface {
            out.append(VenuePill(label: titleize(surface), kind: .surface))
        }
        if hasRates {
            out.append(VenuePill(label: "Paid", kind: .paid))
        }

        // Indoor / outdoor is always shown — exactly one of the two.
        out.append(venue.features.indoor
            ? VenuePill(label: "Indoor", kind: .indoor)
            : VenuePill(label: "Outdoor", kind: .outdoor))

        if venue.features.illuminated {
            out.append(VenuePill(label: "Lights", kind: .lights))
        }
        if venue.features.accessible {
            out.append(VenuePill(label: "Accessible", kind: .accessible))
        }

        // Permit pill is always shown either way so the reader knows
        // we have a definitive answer (matches the web vocabulary).
        out.append(venue.access.requiresPermit
            ? VenuePill(label: "Permit", kind: .permit)
            : VenuePill(label: "No Permit", kind: .noPermit))

        if venue.access.requiresMembership {
            out.append(VenuePill(label: "Membership", kind: .membership))
        }
        if venue.access.requiresBooking {
            out.append(VenuePill(label: "Booking", kind: .booking))
        }

        return out
    }

    // MARK: - Season & Hours
    //
    // Mirrors the web client's `seasonLabel` and `summarizeHours` helpers.
    // We do all the formatting here (rather than in the model) so the
    // Venue type stays free of presentation concerns.

    /// Binary season label. We surface only the open / year-round
    /// distinction here — a list of season names would be noisier than
    /// useful in this slot.
    private var seasonLabel: String {
        venue.availability.seasonalHours.isEmpty ? "Year-round" : "In Season"
    }

    /// Canonical Mon→Sun order used for grouping consecutive days with
    /// identical hours. Anything outside this list is dropped.
    private static let dayOrder = [
        "monday", "tuesday", "wednesday", "thursday",
        "friday", "saturday", "sunday"
    ]

    /// Three-letter day labels for the day-range suffix ("Mon-Fri").
    private static let dayShort: [String: String] = [
        "monday": "Mon", "tuesday": "Tue", "wednesday": "Wed",
        "thursday": "Thu", "friday": "Fri", "saturday": "Sat", "sunday": "Sun"
    ]

    /// "06:30" → "6:30 AM"; "00:00" → "12 AM"; the minutes segment is
    /// dropped when it would be ":00" so we get the compact form the
    /// web client uses.
    private func formatTime(_ hhmm: String) -> String {
        let parts = hhmm.split(separator: ":")
        guard let h = parts.first.flatMap({ Int($0) }) else { return hhmm }
        let m = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
        let ampm = h >= 12 ? "PM" : "AM"
        let h12 = h % 12 == 0 ? 12 : h % 12
        return m > 0
            ? String(format: "%d:%02d %@", h12, m, ampm)
            : "\(h12) \(ampm)"
    }

    /// Roll a list of per-day slots into a single readable string:
    ///   "5:30 AM - 12 AM (Mon-Fri), 7 AM - 12 AM (Sat-Sun)"
    /// Consecutive days with identical hours are collapsed into a single
    /// range so a venue with uniform hours reads as "(Mon-Sun)".
    private func summarizeHours(_ slots: [TimeSlot]) -> String {
        guard !slots.isEmpty else { return "Hours unavailable" }

        // Build a day → "open - close" lookup, ignoring malformed entries.
        var dayHours: [String: String] = [:]
        for slot in slots {
            let day = slot.day.lowercased()
            guard !slot.open.isEmpty, !slot.close.isEmpty else { continue }
            dayHours[day] = "\(formatTime(slot.open)) - \(formatTime(slot.close))"
        }

        // Walk Mon→Sun, starting a new group whenever the hours change or
        // a day is missing from the lookup.
        struct Group { var days: [String]; let hours: String }
        var groups: [Group] = []
        for day in Self.dayOrder {
            guard let hours = dayHours[day] else { continue }
            if var last = groups.last, last.hours == hours {
                last.days.append(day)
                groups[groups.count - 1] = last
            } else {
                groups.append(Group(days: [day], hours: hours))
            }
        }

        return groups.map { group in
            let start = Self.dayShort[group.days.first ?? ""] ?? ""
            let end = Self.dayShort[group.days.last ?? ""] ?? ""
            let range = group.days.count > 1 ? "\(start)-\(end)" : start
            return "\(group.hours) (\(range))"
        }.joined(separator: ", ")
    }

    /// Hours line for the Hours card. Falls back to the first open
    /// seasonal block when there are no year-round regular hours (e.g.
    /// the Riverbank sample, which only defines an open-season schedule).
    private var hoursSummary: String {
        let regular = venue.availability.regularHours
        if !regular.isEmpty { return summarizeHours(regular) }

        if let openSeason = venue.availability.seasonalHours.first(where: { !$0.closed && !$0.hours.isEmpty }) {
            return summarizeHours(openSeason.hours)
        }
        return "Hours unavailable"
    }

    /// SF Symbol paired with each pill kind. Kept as a small lookup so a
    /// future redesign can swap icons without touching the pill-building
    /// logic above.
    private func icon(for kind: VenuePill.Kind) -> String {
        switch kind {
        case .surface:     return "square.grid.2x2"
        case .paid:        return "dollarsign.circle"
        case .indoor:      return "house"
        case .outdoor:     return "tree"
        case .lights:      return "lightbulb"
        case .accessible:  return "figure.roll"
        case .permit:      return "doc.text"
        case .noPermit:    return "doc.text"
        case .membership:  return "person.crop.circle.badge.checkmark"
        case .booking:     return "calendar"
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Details")
                .font(.title3)
                .bold()
                .frame(height: 20)

            // Notable court features
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(pills) { pill in
                        HStack(spacing: 5) {
                            Image(systemName: icon(for: pill.kind))
                                .font(.caption)
                            Text(pill.label)
                                .font(.callout)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.Background.secondary)
                        .overlay(
                            Capsule()
                                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                                .opacity(0.15)
                        )
                        .clipShape(Capsule())
                    }
                }
            }
            
            // Courts — one stacked group per sport, each row of icons
            // scrolls horizontally so a venue with many courts (e.g. the
            // 10-court Riverside Park sample) doesn't blow out the layout
            // on narrow devices.
            VStack(alignment: .leading, spacing: 16) {
                ForEach(courtsBySport, id: \.sport) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            // "10 Tennis Courts" — pluralize naively;
                            // every supported sport uses "court" for its
                            // unit today.
                            Text("\(group.units.count) \(group.sport.capitalized) \(group.units.count == 1 ? "Court" : "Courts")")
                                .font(.callout)
                                .bold()

                            if let surface = dominantSurface(of: group.units) {
                                Text("(\(titleize(surface)) surface)")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Wrap onto multiple rows so a 10-court venue
                        // fills the available width instead of demanding
                        // a horizontal scroll.
                        WrappingHStack(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                            ForEach(group.units) { unit in
                                CourtIcon(color: unit.surfaceColor)
                            }
                        }
                    }
                }
            }
            .padding(.top, 8)

            // Season + Hours — two side-by-side info cards. Each card
            // is just an icon + bold title + caption, matching the web
            // layout. `infoCard` is local so we don't pollute the file
            // with a one-off helper view.
            HStack(alignment: .top, spacing: 24) {
                infoCard(
                    icon: "calendar",
                    title: "Season",
                    detail: seasonLabel
                )

                infoCard(
                    icon: "clock",
                    title: "Hours",
                    detail: hoursSummary
                )
            }
            .padding(.top, 16)

            // Transit — vertical stack of `TransitLabel` rows, one per
            // line that serves the venue. Hidden entirely when the venue
            // has no transit metadata so we don't render an empty header.
            if !venue.transitLines.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transit")
                        .font(.callout)
                        .bold()

                    ForEach(venue.transitLines) { line in
                        TransitLabel(transit: line)
                    }
                }
                .padding(.top, 16)
            }
        }.padding(.all)
    }

    /// Compact icon + title + caption block used by the Season and Hours
    /// columns. `frame(maxWidth: .infinity, alignment: .leading)` lets
    /// the two cards share the row equally.
    @ViewBuilder
    private func infoCard(icon: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.callout)
                    .bold()
            }
            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    // VENUES[3] (Riverside Park Tennis Courts) is the only seed entry
    // populated with `units`, `features`, and `access` — required to
    // exercise every pill variant.
    VenueDetails(venue: VENUES[3])
        .padding(.horizontal)
}
