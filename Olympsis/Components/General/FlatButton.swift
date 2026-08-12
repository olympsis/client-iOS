//
//  FlatButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/12/26.
//

import SwiftUI

/// A flat, bordered "pill" used across the event and venue action rows: an SF
/// Symbol stacked above a bold caption, stretching to fill its share of an
/// `HStack` at a fixed 60-pt height.
///
/// It was extracted to collapse the many near-identical action buttons
/// (Directions, RSVP, Visibility, More, …) — previously each was its own hand
/// rolled `ZStack { RoundedRectangle … }` — into a single definition.
///
/// Pass an `action` to get a tappable `Button`; omit it to get just the styled
/// pill. The label-only form is what you drop into a `Menu`'s `label:` or when
/// the caller attaches its own gesture (see `VenueView`'s visibility popover).
struct FlatButton: View {

    /// Caption shown beneath the icon. Callers pass already-localized text —
    /// e.g. `String(localized: "…", table: "…")` — matching the rest of the app,
    /// so it is rendered verbatim here.
    let title: String

    /// SF Symbol drawn above the title.
    var systemImage: String

    /// The frame the symbol is resized into. Kept explicit because these icons
    /// are intentionally not all square (e.g. the "ellipsis" is wide and short),
    /// so callers set the exact dimensions rather than a single scale.
    var iconSize: CGSize = CGSize(width: 20, height: 20)

    /// Fill color of the pill.
    var background: Color = Color.Background.secondary

    /// Tint applied to the icon and title.
    var foreground: Color = Color.Foreground.default

    /// When true the title uses the app's bold-italic Archivo face so the pill
    /// reads as an active / committed state (matches the RSVP states in Figma).
    var emphasized: Bool = false

    /// Where the icon sits relative to the title.
    /// - `.stacked`: icon centered above the caption — the regular action buttons.
    /// - `.topTrailing`: icon floated to the top-trailing corner with the caption
    ///   centered — the RSVP state buttons in the Figma spec.
    enum IconPlacement {
        case stacked
        case topTrailing
    }

    var iconPlacement: IconPlacement = .stacked

    /// Draws the placeholder shimmer while the data the label depends on is
    /// still loading (e.g. the estimated travel time before venues resolve).
    var isRedacted: Bool = false

    /// Tap handler. When `nil` the view renders as a plain styled label with no
    /// `Button` wrapper, so it can serve as a `Menu` label or take a custom
    /// gesture from the caller.
    var action: (() -> Void)? = nil

    private var icon: some View {
        Image(systemName: systemImage)
            .resizable()
            .frame(width: iconSize.width, height: iconSize.height)
    }

    private var label: some View {
        Text(title)
            .font(titleFont)
            .fontWeight(.bold)
            .lineLimit(1)
            .minimumScaleFactor(0.7) // keep longer labels on one line
    }

    /// The shared pill: a bordered rounded rectangle with the icon and title
    /// arranged per `iconPlacement`.
    private var content: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(maxWidth: .infinity, idealHeight: 60)
                .foregroundStyle(background)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.border, lineWidth: 1)
                }

            // The caption. When stacked it sits beneath the icon; when the icon
            // is floated to the corner it centers on its own.
            Group {
                if iconPlacement == .stacked {
                    VStack(spacing: 6) {
                        icon
                        label
                    }
                } else {
                    label
                }
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, 4)
        }
        // In `.topTrailing` mode the icon is pinned to the corner via an overlay
        // so it aligns to the pill's actual bounds rather than sitting inline.
        .overlay(alignment: .topTrailing) {
            if iconPlacement == .topTrailing {
                icon
                    .foregroundStyle(foreground)
                    .padding(8)
            }
        }
        .redacted(reason: isRedacted ? .placeholder : [])
    }

    /// Emphasized states borrow the same bold-italic face the RSVP sheet uses,
    /// scaling with Dynamic Type via `relativeTo`.
    private var titleFont: Font {
        emphasized
            ? .custom("Archivo-BlackItalic", size: 15, relativeTo: .subheadline)
            : .caption
    }

    var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
                .contentShape(RoundedRectangle(cornerRadius: 10))
        } else {
            content
        }
    }
}

#Preview {
    HStack {
        FlatButton(
            title: "5 mins",
            systemImage: "arrow.trianglehead.turn.up.right.circle.fill"
        ) {}

        FlatButton(
            title: "GOING",
            systemImage: "pencil.circle.fill",
            iconSize: .init(width: 17, height: 17),
            background: Color.Brand.primary,
            foreground: .white,
            emphasized: true,
            iconPlacement: .topTrailing
        ) {}

        FlatButton(
            title: "More",
            systemImage: "ellipsis",
            iconSize: CGSize(width: 23, height: 5)
        ) {}
    }
    .frame(height: 60)
    .padding()
}
