//
//  ViewModifiers.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/11/23.
//

import SwiftUI
import Foundation


struct SettingButton: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
            content
        }
    }
}


struct InputFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.Background.secondary)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                }
            content
                
        }.frame(height: 50)
    }
}

struct BackgroundPillModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.Background.secondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                    }
            }
    }
}

struct SmallPillModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Color.black
                    .opacity(0.21)
            )
            .overlay {
                Capsule()
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .foregroundStyle(.black)
                    .opacity(0.15)
            }
            .clipShape(Capsule())
    }
}

struct NotificationModifier: ViewModifier {
    var manager: NotificationManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let notification = manager.currentNotification, manager.isShowing {
                    NotificationView(
                        metadata: notification,
                        onTap: { manager.handleTap() },
                        onDismiss: { manager.dismiss() }
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top)
                                .combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                    .zIndex(999)
                    .allowsHitTesting(true) // Only the notification itself is tappable
                }
            }
    }
}

extension View {
    func notificationSystem(manager: NotificationManager) -> some View {
        modifier(NotificationModifier(manager: manager))
    }
}

// MARK: - Zoom Navigation Transition (iOS 18+)

/// Source side: marks the view as the zoom origin.
struct ZoomTransitionSourceModifier: ViewModifier {
    var id: String
    var namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *), let namespace {
            content.matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

/// Destination side: zooms in from the matched source.
struct ZoomTransitionModifier: ViewModifier {
    var id: String
    var namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *), let namespace {
            content.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            content
        }
    }
}
