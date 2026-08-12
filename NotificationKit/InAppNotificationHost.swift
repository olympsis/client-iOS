//
//  InAppNotificationHost.swift
//  NotificationKit
//
//  The overlay that presents cards over an app's root view, plus all the
//  motion: slide-down entrance, drag-up-to-dismiss with rubber-banding,
//  flick velocity detection, and Reduce Motion support.
//
//  Attach once at the app's root:
//
//      RootView()
//          .inAppNotifications()                     // defaults
//          .inAppNotifications(style: .myBrand)      // custom look
//

import SwiftUI

public struct InAppNotificationHostModifier: ViewModifier {
    let presenter: InAppNotificationPresenter
    let style: InAppNotificationStyle

    /// Vertical offset of the card's resting position; `hiddenOffset` when
    /// off-screen, 0 when presented. Driven manually (not via SwiftUI
    /// transitions) so a live drag can hand off to the exit animation
    /// without the two motions fighting each other.
    @State private var baseOffset: CGFloat = 0
    /// Live drag translation, added on top of `baseOffset`.
    @State private var dragTranslation: CGFloat = 0
    /// Measured card height; determines how far "off-screen" is.
    @State private var cardHeight: CGFloat = 0
    /// Card opacity — used instead of movement when Reduce Motion is on.
    @State private var cardOpacity: Double = 1
    @State private var hapticTrigger: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                // NOTE: no Spacer/VStack wrapper — the overlay sizes itself
                // to the card, so only the card's rect intercepts touches and
                // the rest of the app stays interactive.
                if let notification = presenter.current {
                    card(for: notification)
                }
            }
            .sensoryFeedback(trigger: hapticTrigger) { _, _ in
                presenter.current?.haptic.map(sensoryFeedback(for:))
            }
            .onChange(of: presenter.phase) { _, phase in
                reactToPhase(phase)
            }
            .onChange(of: presenter.current?.id) {
                // A queued card must never inherit the previous card's drag.
                dragTranslation = 0
            }
    }

    // MARK: - Card + gestures

    @ViewBuilder
    private func card(for notification: InAppNotification) -> some View {
        InAppNotificationCard(notification: notification)
            .environment(\.inAppNotificationStyle, style)
            .padding(.horizontal, style.horizontalMargin)
            .padding(.top, style.topPadding)
            .background {
                // Invisible height probe: how far up "hidden" needs to be.
                GeometryReader { proxy in
                    Color.clear
                        .onChange(of: proxy.size.height, initial: true) { _, newHeight in
                            cardHeight = newHeight
                        }
                }
            }
            // Async images (AsyncImage/KFImage) deliver their content
            // mid-animation, and SwiftUI hands newly-appearing children
            // their FINAL geometry — so without this, an avatar that loads
            // during the slide renders at the resting position while the
            // card is still moving. geometryGroup() isolates the card's
            // geometry so all children ride the animated offset as one
            // rigid unit.
            .geometryGroup()
            .offset(y: baseOffset + dragTranslation)
            .opacity(cardOpacity)
            .onTapGesture { presenter.handleTap() }
            .gesture(dragGesture(for: notification))
            .zIndex(999)
    }

    private func dragGesture(for notification: InAppNotification) -> some Gesture {
        // minimumDistance > 0 lets .onTapGesture coexist with the drag.
        DragGesture(minimumDistance: 2, coordinateSpace: .local)
            .onChanged { value in
                presenter.pauseAutoDismiss()
                let dy = value.translation.height
                // Upward drags track the finger 1:1; downward drags stretch
                // against a rubber band and can never dismiss.
                dragTranslation = dy < 0 ? dy : rubberBand(dy, limit: style.rubberBandLimit)
            }
            .onEnded { value in
                let flickedUp = value.velocity.height < style.dismissVelocity
                let draggedUp = value.translation.height < -style.dismissDistance
                if notification.isDismissible && (flickedUp || draggedUp) {
                    // Fold the drag into the base offset (no visual change),
                    // then let the phase change animate the rest of the exit.
                    baseOffset += dragTranslation
                    dragTranslation = 0
                    presenter.beginDismissal()
                } else {
                    withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                        dragTranslation = 0
                    }
                    presenter.resumeAutoDismiss()
                }
            }
    }

    // MARK: - Phase-driven motion

    private func reactToPhase(_ phase: InAppNotificationPhase) {
        switch phase {
        case .presenting:
            dragTranslation = 0
            hapticTrigger += 1
            if reduceMotion {
                baseOffset = 0
                cardOpacity = 0
                withAnimation(.easeOut(duration: 0.2)) { cardOpacity = 1 }
            } else {
                baseOffset = hiddenOffset
                cardOpacity = 1
                withAnimation(style.entranceAnimation) { baseOffset = 0 }
            }

        case .leaving:
            if reduceMotion {
                withAnimation(.easeOut(duration: 0.2)) { cardOpacity = 0 }
            } else {
                withAnimation(style.exitAnimation) { baseOffset = hiddenOffset }
            }
            // Give the exit animation time to finish, then release the slot.
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                presenter.completeDismissal()
            }

        case .idle:
            baseOffset = 0
            dragTranslation = 0
            cardOpacity = 1
        }
    }

    /// Far enough up that even a tall multi-line card (plus its shadow)
    /// fully clears the top of the screen.
    private var hiddenOffset: CGFloat {
        -(max(cardHeight, style.minHeight) + style.topPadding + 48)
    }

    /// Classic scroll-view rubber-band curve: approaches but never exceeds
    /// `limit` as the finger keeps pulling.
    private func rubberBand(_ distance: CGFloat, limit: CGFloat) -> CGFloat {
        (distance * limit * 0.55) / (limit + 0.55 * distance)
    }

    private func sensoryFeedback(for haptic: InAppNotificationHaptic) -> SensoryFeedback {
        switch haptic {
        case .impactLight: .impact(weight: .light)
        case .impactMedium: .impact(weight: .medium)
        case .success: .success
        case .warning: .warning
        case .error: .error
        }
    }
}

public extension View {
    /// Hosts in-app notification toasts over this view. Attach once, at the
    /// root of the screen hierarchy the toasts should cover.
    func inAppNotifications(
        _ presenter: InAppNotificationPresenter = .shared,
        style: InAppNotificationStyle = .standard
    ) -> some View {
        modifier(InAppNotificationHostModifier(presenter: presenter, style: style))
    }
}
