//
//  OlympsisInAppNotificationStyle.swift
//  Olympsis
//
//  Binds NotificationKit's theme tokens to Olympsis's design language.
//  This is the only place the app and the kit touch visually — deleting
//  this file (and the .inAppNotifications call site) fully detaches the kit.
//

import SwiftUI

extension InAppNotificationStyle {
    static var olympsis: InAppNotificationStyle {
        var style = InAppNotificationStyle.standard
        style.background = AnyShapeStyle(Color.Background.secondary)
        style.borderColor = .primary.opacity(0.1)
        // Explicit emphasis fonts so `**bold**` runs use Archivo's real bold
        // face instead of a synthesized one (see InAppNotificationText).
        style.titleFont = .custom("Archivo-SemiBold", size: 15, relativeTo: .subheadline)
        style.titleEmphasisFont = .custom("Archivo-Bold", size: 15, relativeTo: .subheadline)
        style.subtitleFont = .custom("Archivo-Regular", size: 14, relativeTo: .footnote)
        style.subtitleEmphasisFont = .custom("Archivo-SemiBold", size: 14, relativeTo: .footnote)
        return style
    }
}
