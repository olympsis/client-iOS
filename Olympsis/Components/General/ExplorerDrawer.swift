//
//  ExplorerDrawer.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/5/26.
//
//  Bottom-anchored resizable drawer. Replaces SwiftUI's `.sheet` for the
//  events explorer so the system tab bar stays on top — the drawer is
//  just an overlay subview, not a system presentation.
//
//  Kept intentionally minimal: one struct, one piece of state, one
//  gesture, one snap animation. Earlier iterations added a
//  parent/child split, interactive springs during drag, momentum
//  conversion to interpolating-spring `initialVelocity`, etc., and
//  every layer made the motion *worse* in practice. This version
//  tracks the finger 1:1 during drag and runs a plain spring on
//  release. That's it.
//

import SwiftUI

/// One of three discrete heights the drawer can rest at.
enum DrawerDetent: CaseIterable, Hashable {
    case small
    case medium
    case large

    /// Resolved height in points given the drawer's available space.
    func height(in totalHeight: CGFloat) -> CGFloat {
        switch self {
        case .small:
            return 110
        case .medium:
            return min(totalHeight * 0.5, max(totalHeight - 80, 0))
        case .large:
            return max(totalHeight - 50, 0)
        }
    }
}

/// Bottom-anchored resizable drawer. Attach via `.overlay(alignment: .bottom)`
/// to the view it should float over (e.g. the map). The overlay only
/// extends to the drawer's painted height, so the area above stays
/// fully interactive.
///
/// Optional `topAccessory` slot renders *above* the drawer's painted
/// surface (no background) and shares the same slide offset, so any
/// floating buttons placed there ride up with the drawer instead of
/// staying pinned to the screen.
struct ExplorerDrawer<TopAccessory: View, Content: View>: View {

    @Binding var detent: DrawerDetent
    @ViewBuilder var topAccessory: () -> TopAccessory
    @ViewBuilder var content: () -> Content

    @State private var dragOffset: CGFloat = 0

    /// Approximate available height (screen − nav bar − tab bar). We
    /// don't need to be exact; the detents are coarse buckets.
    private var totalHeight: CGFloat {
        UIScreen.main.bounds.height - 150
    }

    var body: some View {
        // Drawer is laid out at `largeHeight` and slides DOWN via
        // `.offset(y:)` to appear shorter — offset is a transform, so
        // there's no per-frame layout pass during drag. The parent
        // view's `.clipped()` hides the off-bottom portion.
        let largeHeight = DrawerDetent.large.height(in: totalHeight)
        let smallHeight = DrawerDetent.small.height(in: totalHeight)
        let baseOffset = largeHeight - detent.height(in: totalHeight)
        let liveOffset = min(
            max(baseOffset + dragOffset, 0),
            largeHeight - smallHeight
        )
        // Corner radius derived from the live offset so it animates
        // smoothly with the spring instead of snapping at the end of
        // the detent change. At full-up (offset 0) the drawer reads
        // as part of the screen → no corner; once you start dragging
        // away, corners ease in over the first ~20pt of offset.
        let cornerRadius = min(16, max(0, liveOffset * 0.8))

        VStack(spacing: 0) {
            // Caller-provided accessory above the drawer surface.
            // Shares the slide transform below so it rides with the
            // drawer; not painted into the drawer's background, so
            // it floats over the underlying view (e.g. the map).
            topAccessory()

            VStack(spacing: 0) {
                // Grabber — the only area that owns the drag gesture.
                Capsule()
                    .fill(Color.secondary.opacity(0.6))
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                // Snap to whichever detent height is
                                // closest to where the finger released.
                                let target = detent.height(in: totalHeight) - value.translation.height
                                let next = DrawerDetent.allCases.min { a, b in
                                    abs(a.height(in: totalHeight) - target) <
                                    abs(b.height(in: totalHeight) - target)
                                } ?? .medium

                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    dragOffset = 0
                                    detent = next
                                }
                            }
                    )

                content()
            }
            .frame(maxWidth: .infinity)
            .frame(height: largeHeight)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    topTrailingRadius: cornerRadius
                )
                .fill(Color(uiColor: .systemBackground))
                .ignoresSafeArea(edges: .bottom)
            )
        }
        .offset(y: liveOffset)
        // Pin the drawer to its detent regardless of the keyboard.
        // Without this, focusing a TextField (e.g. the floating search
        // bar) inflates the bottom safe area by the keyboard height
        // and shoves the entire drawer upward. Anything that needs to
        // ride above the keyboard (the search bar itself) opts back in
        // via `.safeAreaInset(edge: .bottom)` on a different layer.
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// Convenience initializer so existing callers that don't need a top
// accessory keep the original two-arg shape.
extension ExplorerDrawer where TopAccessory == EmptyView {
    init(
        detent: Binding<DrawerDetent>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            detent: detent,
            topAccessory: { EmptyView() },
            content: content
        )
    }
}

#Preview("Drawer over fake map") {
    @Previewable @State var detent: DrawerDetent = .medium

    ZStack {
        LinearGradient(
            colors: [.green.opacity(0.4), .blue.opacity(0.4), .gray.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 12) {
            ForEach(0..<5) { _ in
                Circle()
                    .fill(.white)
                    .frame(width: 28, height: 28)
                    .shadow(radius: 2)
            }
        }
    }
    .overlay(alignment: .bottom) {
        ExplorerDrawer(detent: $detent) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Detent: \(String(describing: detent))")
                    .font(.headline)

                HStack {
                    ForEach(DrawerDetent.allCases, id: \.self) { d in
                        Button(String(describing: d).capitalized) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                detent = d
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<40) { i in
                            Text("Sample list row #\(i)")
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
        }
    }
    .clipped()
}
