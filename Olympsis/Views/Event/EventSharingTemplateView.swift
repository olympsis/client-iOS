//
//  EventSharingTemplateView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/9/24.
//

import SwiftUI

struct EventSharingTemplateView: View {
    
    var template: Int
    
    var body: some View {
        
        Group {
            switch template {
            case 0:
                VStack {
                    HStack {
                        Rectangle()
                            .frame(width: 60, height: 12)
                        Spacer()
                    }
                    
                    HStack {
                        VStack(spacing: 5) {
                            Rectangle()
                                .frame(width: 60, height: 12)
                            Rectangle()
                                .frame(width: 60, height: 12)
                        }
                        Spacer()
                    }.padding(.top)
                }
            case 1:
                VStack {
                    Rectangle()
                        .frame(width: 60, height: 12)
                        .padding(.top)
                    
                    HStack {
                        VStack(spacing: 5) {
                            Rectangle()
                                .frame(width: 60, height: 12)
                            Rectangle()
                                .frame(width: 60, height: 12)
                        }
                        Spacer()
                    }.padding(.top, 5)
                }
            case 2:
                VStack {
                    Rectangle()
                        .frame(width: 60, height: 12)
                        .padding(.top)
                    Rectangle()
                        .frame(width: 60, height: 12)
                    Rectangle()
                        .frame(width: 60, height: 12)
                }
            case 3:
                VStack {
                    Rectangle()
                        .frame(width: 30, height: 12)
                        .padding(.top)
                    
                    VStack(spacing: 5) {
                        Rectangle()
                            .frame(width: 60, height: 12)
                        Rectangle()
                            .frame(width: 60, height: 12)
                    }.padding(.top, 5)
                }
            default:
                EmptyView()
            }
        }
        .frame(width: 100, height: 100)
        .background {
            Color.background
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    EventSharingTemplateView(template: 3)
}
