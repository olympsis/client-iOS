//
//  ToastView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/15/23.
//

import SwiftUI

struct ToastView: View {
    
    @State var toast: Toast
    
    var body: some View {
        HStack(alignment: .center) {
            switch toast.style {
            case .error:
                HStack(alignment: .center) {
                    Image(systemName: "x.square")
                        .foregroundColor(.white)
                    HStack {
                        Text(toast.message)
                            .foregroundColor(.white)
                    }.lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .warning:
                HStack(alignment: .center) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.white)
                    HStack {
                        Text(toast.message)
                            .foregroundColor(.white)
                    }.lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .success:
                HStack(alignment: .center) {
                    HStack {
                        Text(toast.message)
                            .foregroundColor(.white)
                    }.lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .info:
                HStack(alignment: .center) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                    HStack {
                        Text(toast.message)
                            .foregroundColor(.white)
                    }.lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            case .newPost:
                HStack(alignment: .center) {
                    Circle()
                        .frame(width: 40)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(toast.title + " ")
                                .foregroundColor(.white)
                            +
                            Text((toast.actor ?? "") + " ")
                                .bold()
                                .foregroundColor(.white)
                            +
                            Text(toast.message)
                                .foregroundColor(.white)
                            
                        }.lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            case .message:
                HStack(alignment: .center) {
                    Circle()
                        .frame(width: 40)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        Text(toast.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text((toast.actor ?? "") + ": ")
                            .foregroundColor(.white)
                        +
                        Text(toast.message)
                            .foregroundColor(.white)
                    }
                }
            case .newEvent:
                HStack(alignment: .center) {
                    Circle()
                        .frame(width: 40)
                        .padding(.trailing, 5)
                    VStack {
                        HStack(alignment: .center) {
                            Text(toast.title + " ")
                                .foregroundColor(.white)
                            +
                            Text((toast.actor ?? "") + " ")
                                .bold()
                                .foregroundColor(.white)
                            +
                            Text(toast.message)
                                .foregroundColor(.white)
                        }.lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40)
                }
            case .eventStatus:
                HStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        Text(toast.title)
                            .bold()
                            .foregroundColor(.white)
                        Text(toast.message)
                            .foregroundColor(.white)
                    }
                }
            }
            Spacer()
        }.padding(.horizontal)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color("dark-color"))
                    .frame(height: 60)
                    .padding(.horizontal, 5)
            }
            .frame(height: 40)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(toast: Toast(style: .message, actor: "davidhamash", title: "[SLC FC] Goonies Squad", message: "No internet connection")).environmentObject(SessionStore())
    }
}
