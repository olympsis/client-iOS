//
//  ExplorerPagePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/18/26.
//

import SwiftUI

/// Two-segment control that drives the events/venues page selection in the
/// `Events` navigation bar.
///
/// Why not `Picker(.segmented)`: the system style renders at a fixed ~47pt
/// height and ignores every sizing lever — `frame(height:)`, `controlSize(_:)`,
/// and `font(_:)` all have no effect (verified against the live view
/// hierarchy). Scaling it down with a transform shrinks the *text* along with
/// the control, leaving the labels far too small for a nav-bar title. Plain
/// SwiftUI buttons give independent control over the track height and the
/// label size, which is the whole point here.
///
/// The sliding thumb is positioned from measured segment widths rather than
/// `matchedGeometryEffect`. Two bugs drove that choice, both symptoms of the
/// thumb's frame being resolved from *another view's* geometry:
///  • Painting the thumb inside the selected segment made every change an
///    insert + remove pair, which animated one direction and snapped the other.
///  • Even as a single re-targeted view, the consumer has no source frame on
///    the first layout pass after the toolbar is rebuilt (which happens each
///    time you navigate back to Events), so it settled into place visibly —
///    the twitch on appear.
/// Measured widths make the thumb's frame a pure function of local state, so
/// the first painted frame is already correct and both directions animate the
/// same way.
struct ExplorerPagePicker: View {

    @Binding var selection: EVENT_EXPLORER_STATE

    /// Overall height of the control. Defaults to 34pt, which sits
    /// comfortably inside the 54pt inline navigation bar.
    var height: CGFloat = 34

    /// Label size. Deliberately independent of `height` — that's the
    /// separation the system picker doesn't offer.
    var font: Font = .subheadline

    /// Measured width of each segment, keyed by page. Drives both the thumb's
    /// width and its offset, so no cross-view geometry lookup is needed.
    @State private var segmentWidths: [EVENT_EXPLORER_STATE: CGFloat] = [:]

    private var pages: [EVENT_EXPLORER_STATE] { EVENT_EXPLORER_STATE.allCases }

    /// True once every segment has reported a width. The thumb stays hidden
    /// until then so the un-measured first frame never paints.
    private var isMeasured: Bool {
        pages.allSatisfy { (segmentWidths[$0] ?? 0) > 0 }
    }

    /// Distance from the leading edge to the selected segment: the summed
    /// width of every segment before it.
    private var thumbOffset: CGFloat {
        pages.prefix { $0 != selection }
            .reduce(0) { $0 + (segmentWidths[$1] ?? 0) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(pages, id: \.self) { page in
                segment(for: page)
            }
        }
        // Attached to the HStack (not the padded container) so the thumb's
        // leading edge lines up with the first segment, inside the 3pt inset.
        .background(alignment: .leading) { thumb }
        .padding(3)
        .frame(height: height)
        // Intrinsic width so the control hugs its labels rather than
        // stretching across the gap between the toolbar's buttons.
        .fixedSize(horizontal: true, vertical: false)
        .background { track }
        // One animation for the whole control, scoped to `selection`. Scoping
        // matters: width measurements land in their own transactions and must
        // NOT animate, or the thumb would grow from zero on first appearance.
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: selection)
    }

    /// The control's background "groove". Glass on iOS 26 so the map bleeds
    /// through, an opaque tertiary fill below that.
    @ViewBuilder
    private var track: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(.clear)
                .glassEffect(.regular, in: .capsule)
        } else {
            Capsule()
                .fill(Color.Background.tertiary)
        }
    }

    /// The sliding selection indicator. Height comes from the background's
    /// proposal (the HStack's), width and position from the measurements.
    private var thumb: some View {
        Capsule()
            .fill(Color.Background.secondary)
            .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
            .frame(width: segmentWidths[selection] ?? 0)
            .offset(x: thumbOffset)
            .opacity(isMeasured ? 1 : 0)
    }

    @ViewBuilder
    private func segment(for page: EVENT_EXPLORER_STATE) -> some View {
        let isSelected = selection == page
        Button {
            selection = page
        } label: {
            label(for: page, isSelected: isSelected)
                .padding(.horizontal, 14)
                // Fill the track's height so the tap target covers the
                // full segment, not just the text's line box.
                .frame(maxHeight: .infinity)
                .contentShape(Capsule())
                .background { widthReader(for: page) }
        }
        .buttonStyle(.plain)
        // Announce the segment's state to VoiceOver — the plain buttons
        // don't carry the selection trait the way `Picker` does.
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// Segment label. The hidden semibold copy underneath reserves the widest
    /// the text can ever be, so switching the visible weight on selection
    /// doesn't change the segment's width — if it did, every selection change
    /// would relayout the stack and re-measure mid-slide.
    private func label(for page: EVENT_EXPLORER_STATE, isSelected: Bool) -> some View {
        ZStack {
            Text(page.localized)
                .font(font)
                .fontWeight(.semibold)
                .hidden()

            Text(page.localized)
                .font(font)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
        }
    }

    /// Width probe. `onGeometryChange(for:of:action:)` would be tidier but is
    /// iOS 18+; the app ships to iOS 17.
    private func widthReader(for page: EVENT_EXPLORER_STATE) -> some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { record(proxy.size.width, for: page) }
                .onChange(of: proxy.size.width) { _, width in
                    record(width, for: page)
                }
        }
    }

    /// Stores a measurement without animating it. An ambient transition (the
    /// navigation push, a tab change) would otherwise animate the thumb from
    /// zero width the first time the widths land.
    private func record(_ width: CGFloat, for page: EVENT_EXPLORER_STATE) {
        guard segmentWidths[page] != width else { return }
        withAnimation(nil) {
            segmentWidths[page] = width
        }
    }
}

#Preview {
    @Previewable @State var selection: EVENT_EXPLORER_STATE = .events

    ExplorerPagePicker(selection: $selection)
        .padding()
        .background(Color.Background.primary)
}
