//
//  ToastManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/24.
//

import SwiftUI
import Foundation
import Kingfisher
import AlertToast
import NotificationCenter

class ToastManager: ObservableObject {
    
    @State private var timerWorkItem: DispatchWorkItem?
    
    @Published var isPresented: Bool = false
    @Published var toastPosition: TOAST_POSITION = .top
    @Published var toastContent: ToastContent = ToastContent(view: { EmptyView() })
    
    @Environment(\.openURL) private var openURL
    
    static let center = NotificationCenter()
    static let shared: ToastManager = ToastManager()
    
    private var delay: TimeInterval = 4.0
    
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

            guard let data = notification.userInfo,
                  let raw = data["type"] as? String,
                  let type = TOAST_TYPE(rawValue: raw),
                  let content = data["content"] as? String,
                  let position = TOAST_POSITION(rawValue: data["position"] as? String ?? "top") else {
                return
            }
            
            let metadata = generateMetadata(data: data)
            let view = await ToastView(type, content: content, metadata: metadata)

            // Pre-fetch images
            var images: [URL] = []
            if let userImageURL = metadata.userImageURL {
                guard let url = generateImageURL(userImageURL) else {
                    return
                }
                images.append(url)
            }
            if let postImageURL = metadata.postImageURL {
                guard let url = generateImageURL(postImageURL) else {
                    return
                }
                images.append(url)
            }
            if let groupImageURL = metadata.groupImageURL {
                guard let url = generateImageURL(groupImageURL) else {
                    return
                }
                images.append(url)
            }
            if let eventImageURL = metadata.eventImageURL {
                guard let url = generateImageURL(eventImageURL) else {
                    return
                }
                images.append(url)
            }
            
            let prefetcher = ImagePrefetcher(urls: images)
            prefetcher.start()

            var url: URL?
            
            if let urlString = metadata.url {
                url = URL(string: urlString)
            }
            
            await self.showToast(
                ToastContent(
                    view: { view },
                    url: url
                ),
                position: position
            )
        }
    }
}
