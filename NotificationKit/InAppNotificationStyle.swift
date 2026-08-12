//
//  InAppNotificationStyle.swift
//  NotificationKit
//
//  Theme tokens for the notification card and its motion. Every visual
//  constant lives here so no view file hardcodes numbers, and host apps
//  can rebrand the card without touching kit views.
//

import SwiftUI

public struct InAppNotificationStyle {
    // MARK: Shape & background
    public var cornerRadius: CGFloat = 20
    /// `AnyShapeStyle` so hosts can use a material, a solid color, or a
    /// gradient interchangeably. The default material adapts to light/dark.
    public var background: AnyShapeStyle = AnyShapeStyle(.regularMaterial)
    public var borderColor: Color = .primary.opacity(0.08)
    public var borderWidth: CGFloat = 1
    public var shadowColor: Color = .black.opacity(0.18)
    public var shadowRadius: CGFloat = 12
    public var shadowYOffset: CGFloat = 4

    // MARK: Layout
    /// Distance from the leading/trailing screen edges.
    public var horizontalMargin: CGFloat = 12
    /// Extra breathing room below the top safe area (Dynamic Island).
    public var topPadding: CGFloat = 8
    public var contentPadding = EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
    public var contentSpacing: CGFloat = 12
    /// Minimum height, NOT a fixed height — the card grows with Dynamic
    /// Type and multi-line subtitles.
    public var minHeight: CGFloat = 64
    public var imageSize: CGFloat = 44
    public var leadingImageShape: InAppNotificationImageShape = .circle
    public var trailingImageShape: InAppNotificationImageShape = .rounded(6)

    // MARK: Typography
    public var titleFont: Font = .subheadline.weight(.semibold)
    /// Real bold face for `**emphasized**` title runs. Leave nil for system
    /// fonts (SwiftUI's built-in bold trait handles those correctly); set it
    /// when using a custom family to avoid synthesized bold.
    public var titleEmphasisFont: Font? = nil
    public var titleColor: Color = .primary
    public var titleLineLimit: Int = 1
    public var subtitleFont: Font = .footnote
    public var subtitleEmphasisFont: Font? = nil
    public var subtitleColor: Color = .secondary
    public var subtitleLineLimit: Int = 2

    // MARK: Motion & gestures
    public var entranceAnimation: Animation = .spring(duration: 0.45, bounce: 0.22)
    public var exitAnimation: Animation = .spring(duration: 0.28, bounce: 0)
    /// Upward drag distance (pt) past which release dismisses.
    public var dismissDistance: CGFloat = 40
    /// Upward flick velocity (pt/s, negative = up) past which release dismisses.
    public var dismissVelocity: CGFloat = -450
    /// Max downward stretch when rubber-banding a downward drag.
    public var rubberBandLimit: CGFloat = 60

    public init() {}

    public static var standard: InAppNotificationStyle { InAppNotificationStyle() }
}

private struct InAppNotificationStyleKey: EnvironmentKey {
    static let defaultValue = InAppNotificationStyle.standard
}

public extension EnvironmentValues {
    var inAppNotificationStyle: InAppNotificationStyle {
        get { self[InAppNotificationStyleKey.self] }
        set { self[InAppNotificationStyleKey.self] = newValue }
    }
}
