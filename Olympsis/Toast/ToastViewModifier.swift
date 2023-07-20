//
//  ToastViewModifier.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/16/23.
//

import SwiftUI
import Foundation

struct ToastViewModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var toast: Toast
    
    enum DisplayPosition {
        case top
        case bottom
    }
    
    func body(content: Content) -> some View {
        switch toast.style {
        case .error:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        case .warning:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        case .success:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        case .info:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        case .newPost:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        case .message:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        case .newEvent:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        case .eventStatus:
            return content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    ToastViewer()
                        .onChange(of: isPresented) { newValue in
                            guard newValue == true else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    isPresented = false
                                }
                            }
                        }
                }
        }
        
    }
    
    @ViewBuilder func ToastViewer() -> some View {
        if isPresented {
            switch toast.style {
            case .error:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: -20)
                        .transition(.offset(y: 1000))
                }
            case .warning:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: -20)
                        .transition(.offset(y: 1000))
                }
            case .success:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: -20)
                        .transition(.offset(y: 1000))
                }
            case .info:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: -20)
                        .transition(.offset(y: 1000))
                }
            case .newPost:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: 0)
                        .transition(.offset(y: -1000))
                }
            case .message:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: 0)
                        .transition(.offset(y: -1000))
                }
            case .newEvent:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: 0)
                        .transition(.offset(y: -1000))
                }
            case .eventStatus:
                withAnimation {
                    ToastView(toast: toast)
                        .offset(y: 0)
                        .transition(.offset(y: -1000))
                }
            }
        }
    }
      
}

extension View {

    func toast(isPresented: Binding<Bool>, toast: Binding<Toast>) -> some View {
        self.modifier(ToastViewModifier(isPresented: isPresented, toast: toast))
    }
}
