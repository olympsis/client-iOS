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

struct NotificationViewModifier: ViewModifier {
    var manager: NotificationManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let notification = manager.currentNotification, manager.isShowing {
//                    NotificationView(
//                        notification: notification,
//                        onTap: { manager.handleTap() },
//                        onDismiss: { manager.dismiss() }
//                    )
//                    .padding(.horizontal)
//                    .padding(.top, 60)
//                    .transition(
//                        .asymmetric(
//                            insertion: .move(.top)
//                                .combined(with: .opacity),
//                            removal: .opacity
//                        )
//                    )
//                    .zIndex(999)
//                    .allowsHitTesting(true) // Only the notification itself is tappable
                }
            }
    }
}
