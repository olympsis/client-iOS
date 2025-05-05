//
//  ToastModifier.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/25/24.
//

import SwiftUI
import Foundation

public enum DisplayPosition {
    case top
    case bottom
}

public struct ToastContent {
    let view: () -> any View
    let url: URL?
    
    public init(view: @escaping () -> any View, url: URL?=nil) {
        self.view = view
        self.url = url
    }
}

public struct ToastViewModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var position: TOAST_POSITION
    @Binding var toastContent: ToastContent
    @Environment(\.openURL) private var openURL
    
    var delay: TimeInterval = 4.0
    
    @State private var timerWorkItem: DispatchWorkItem?
    
    private func hideToast() {
        isPresented = false
    }
    
    /// Resets the timer if we have another notification to display before dismissing the
    /// currently presented notification.
    private func resetTimer() {
         // Cancel the previous work item if it exists
         timerWorkItem?.cancel()
         
         // Create a new DispatchWorkItem
         let workItem = DispatchWorkItem {
             hideToast()
         }
         
         // Assign the new work item
         timerWorkItem = workItem
         
         // Dispatch the work item after the delay
         DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
     }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: position == .top ? .top : .bottom) {
                if isPresented {
                    AnyView(toastContent.view())
                        .padding(.horizontal, 10)
                        .padding(position == .top ? .top : .bottom, position == .top ? 0 : 15)
                        .onTapGesture {
                            if let url = toastContent.url {
                                openURL(url)
                            }
                            hideToast()
                        }
                        .transition(.move(edge: position == .top ? .top : .bottom))
                        .animation(.easeInOut, value: isPresented)
                }
            }
            .onChange(of: isPresented) { _, newValue in
                guard newValue == true else {
                    return
                }
                resetTimer()
            }
    }
}

extension View {
    public func toast(isPresented: Binding<Bool>, position: Binding<TOAST_POSITION>, content: Binding<ToastContent>) -> some View {
        modifier(ToastViewModifier(isPresented: isPresented, position: position, toastContent: content))
    }
}
