//
//  TabBar.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

/// Floating glass-pill tab bar shared across all supported iOS versions.
///
/// We can't use the system `TabView` bar because the profile tab needs to
/// show the user's avatar — the system `Tab(_:systemImage:value:)` API
/// only accepts a `systemImage` string, with no escape hatch for an
/// arbitrary view. Building our own bar also lets us own the look so it
/// stays consistent across iOS 17 / 18 / 26+ instead of looking like
/// two different products depending on the device.
///
/// Visual model:
/// - A single floating capsule pinned near the bottom of the screen.
/// - iOS 26+: the system liquid-glass material (`glassEffect`) so the
///   bar picks up live blur of content scrolling underneath, matching
///   the new system toolbars.
/// - iOS 17 / 18: `.regularMaterial` inside a `Capsule` + a hairline
///   stroke and a soft shadow to read as a floating element.
/// - The selected tab is marked by a tinted `Circle` behind its icon
///   driven by `matchedGeometryEffect`, so the highlight smoothly
///   slides between tabs the way the iOS 26 toolbar's selection chip
///   does instead of cross-fading in place.
struct TabBar: View {

    @Binding var currentTab: ViewTab

    let eventRouter: EventRouter
    let profileRouter: ProfileRouter

    @Environment(SessionStore.self) private var session
    @Environment(\.colorScheme) private var colorScheme

    /// Namespace for the selected-state indicator's
    /// `matchedGeometryEffect`. Sharing one namespace across all
    /// buttons is what lets the highlight pill slide from one tab
    /// to another when `currentTab` changes.
    @Namespace private var indicatorNamespace

    /// Tabs the bar renders, in display order. Other `ViewTab` cases
    /// (`.home`, `.club`, `.activity`) are intentionally omitted —
    /// they were cut for the MVP resubmission. Re-adding a tab is a
    /// one-line change here plus a corresponding entry in
    /// `iconView(for:)` / `navigateToRoot(for:)`.
    private let tabs: [ViewTab] = [.events, .profile]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tabs, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .modifier(GlassPillBackground())
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Buttons

    /// One tab slot. The 44pt square comes from Apple's HIG touch-target
    /// guidance — anything smaller is hard to hit reliably with a thumb.
    @ViewBuilder
    private func tabButton(for tab: ViewTab) -> some View {
        let isSelected = currentTab == tab

        Button {
            handleTap(tab)
        } label: {
            ZStack {
                if isSelected {
                    // Tinted indicator. `matchedGeometryEffect` ties
                    // this to the other tab buttons' equivalents so
                    // SwiftUI animates a single moving pill between
                    // tabs rather than cross-fading two separate ones.
                    Capsule()
                        .fill(.gray)
                        .opacity(0.1)
                        .matchedGeometryEffect(
                            id: "tabIndicator",
                            in: indicatorNamespace
                        )
                }
                iconView(for: tab, isSelected: isSelected)
            }
            .frame(width: 66, height: 44)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.rawValue))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// Renders the icon/avatar inside the button. Each case picks the
    /// foreground treatment for the current selection state — selected
    /// icons go white so they read against the tinted indicator pill
    /// underneath.
    @ViewBuilder
    private func iconView(for tab: ViewTab, isSelected: Bool) -> some View {
        switch tab {
        case .events:
            Image(systemName: "calendar")
                .imageScale(.medium)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? Color.white : Color.Foreground.default)

        case .profile:
            TabBarProfileLabel(currentTab: $currentTab)
                .environment(session)

        case .home, .club, .activity:
            EmptyView()
        }
    }

    // MARK: - Tap handling

    /// Spring chosen to roughly match the duration / damping of the
    /// `matchedGeometryEffect` indicator slide, so the icon swap and
    /// the highlight movement land together.
    private func handleTap(_ tab: ViewTab) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            if currentTab == tab {
                // Already on this tab → pop its nav stack to root,
                // matching the iOS system tab bar's behavior.
                navigateToRoot(for: tab)
            } else {
                currentTab = tab
            }
        }
    }

    private func navigateToRoot(for tab: ViewTab) {
        switch tab {
        case .events:
            eventRouter.navigateToRoot()
        case .profile:
            profileRouter.navigateToRoot()
        case .home, .club, .activity:
            break
        }
    }
}

// MARK: - Background

/// The pill's background material. Split out as a `ViewModifier` so the
/// availability branch lives in one place — the iOS 26 / fallback split
/// would otherwise duplicate the rest of the pill chrome at the call
/// site, and accidentally diverging the two paths is exactly the bug
/// this component is trying to avoid.
private struct GlassPillBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // `glassEffect` ships the system's live blur + specular
            // highlight + edge treatment in one call. The shape arg
            // is what gives the bar its capsule outline.
            content.glassEffect(.regular, in: .capsule)
        } else {
            // Pre-iOS-26 fallback. The hairline + shadow do the work
            // that the glass material's edge highlight does for free
            // on newer systems, so the bar still reads as a lifted
            // floating element instead of a flat blurred rectangle.
            content
                .background(.regularMaterial, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.Brand.primary.opacity(0.12), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            Spacer()
            TabBar(
                currentTab: .constant(.events),
                eventRouter: EventRouter(),
                profileRouter: ProfileRouter()
            )
        }
    }
    .environment(SessionStore())
}
