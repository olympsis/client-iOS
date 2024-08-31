//
//  ToastManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/24.
//

import SwiftUI
import Foundation
import NotificationCenter

class ToastManager: ObservableObject {
    
    @Published var isPresented: Bool = false
    @Published var toastPosition: TOAST_POSITION = .top
    @Published var toastContent: ToastContent = ToastContent(view: { EmptyView() })
    
    @Environment(\.openURL) private var openURL
    
    static let shared: ToastManager = ToastManager()
    
    private var delay: TimeInterval = 4.0
    static let center = NotificationCenter()
    
    @State private var timerWorkItem: DispatchWorkItem?
    
    init() {
        Task {
            await listenForNotifications()
        }
    }
    
    @MainActor
    func showToast(_ content: ToastContent, position: TOAST_POSITION = .top) {
        isPresented = true
        toastPosition = position
        toastContent = content
    }
    
    func sendNotification(note: Notification) {
        ToastManager.center.post(note)
    }
    
    func listenForNotifications() async {
        for await notification in ToastManager.center.notifications(named: Notification.Name(rawValue: "toast-system")) {
            print(notification)
            await self.showToast(ToastContent(view: {
                Group {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 50)
                            .foregroundStyle(Color.foreground)
                        Text("Toast Content")
                            .foregroundStyle(Color.background)
                    }
                }
            }), position: .bottom)
        }
    }
}
