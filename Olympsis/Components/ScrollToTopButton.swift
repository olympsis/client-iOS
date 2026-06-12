//
//  ScrollToTopButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/11/26.
//

import SwiftUI

/// Shared "jump back to top" affordance for long scroll views (iOS 18+).
///
/// A floating, glass bottom-trailing button appears once the user scrolls past
/// a threshold and, on tap, animates the scroll view back to the top edge.
///
/// Usage — apply directly to a `ScrollView`:
/// ```
/// ScrollView {
///     // …content…
/// }
/// .scrollToTopButton()
/// ```
///
/// Built on iOS 18's `ScrollPosition.scrollTo(edge:)`, which scrolls to the
/// top *edge* of the content directly. That's the key reliability win over
/// `ScrollViewProxy.scrollTo(id:)`: the latter has to animate through (and
/// realize) every lazy cell on the way up, which stalls partway on long lists,
/// whereas the edge scroll lands squarely at the top in one shot.

private enum ScrollToTop {
    /// How far (in points) the user must scroll down before the button reveals.
    static let revealThreshold: CGFloat = 150
}

// MARK: - Floating button

/// The circular up-arrow button itself. Uses the iOS 26 liquid-glass material
/// so it reads as a floating control over scrolling content, falling back to a
/// regular material on older systems.
struct ScrollToTopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 48, height: 48)
                .modifier(GlassCircleBackground())
        }
        .accessibilityLabel(Text("Scroll to top"))
    }
}

/// Circular glass background for the button. `glassEffect(_:in:)` is iOS 26+,
/// so older systems get a material capsule with a hairline border + shadow.
private struct GlassCircleBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: Circle())
        } else {
            content
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().strokeBorder(Color(.systemGray4), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
    }
}

// MARK: - Modifier

/// Attaches the offset tracking + floating button to a `ScrollView`. Apply it
/// to the `ScrollView` (not the inner content) so the button overlays the
/// viewport.
@available(iOS 18.0, *)
private struct ScrollToTopModifier: ViewModifier {
    /// Lets a shared scroll view (e.g. the Events explorer, which swaps between
    /// events and venues) enable the button only on the page that wants it.
    let isEnabled: Bool

    /// Drives the programmatic scroll-to-top via `scrollTo(edge:)`.
    @State private var scrollPosition = ScrollPosition()

    /// How far the user has scrolled down from the top, in points. Positive
    /// when scrolled down, ~0 at the top.
    @State private var scrolledDistance: CGFloat = 0

    /// Visible once the user has scrolled down past the threshold.
    private var isVisible: Bool {
        isEnabled && scrolledDistance > ScrollToTop.revealThreshold
    }

    func body(content: Content) -> some View {
        content
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                // contentOffset.y sits at -topInset at rest; add the inset back
                // so "top" reads as 0 and scrolling down is positive.
                geo.contentOffset.y + geo.contentInsets.top
            } action: { _, newValue in
                scrolledDistance = newValue
            }
            .overlay(alignment: .bottomTrailing) {
                if isVisible {
                    ScrollToTopButton {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            scrollPosition.scrollTo(edge: .top)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
    }
}

extension View {
    /// Adds a floating scroll-to-top button that appears after the user scrolls
    /// down (iOS 18+; a no-op on earlier systems). Apply it to a `ScrollView`.
    @ViewBuilder
    func scrollToTopButton(isEnabled: Bool = true) -> some View {
        if #available(iOS 18.0, *) {
            modifier(ScrollToTopModifier(isEnabled: isEnabled))
        } else {
            self
        }
    }
}
