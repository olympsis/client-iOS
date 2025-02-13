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
                VStack(spacing: 2) {
                    HStack {
                        Rectangle()
                            .frame(width: 40, height: 10)
                            .foregroundStyle(Color.foreground)
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Rectangle()
                                .frame(width: 30, height: 10)
                                .foregroundStyle(Color.foreground)
                            Rectangle()
                                .frame(width: 55, height: 10)
                                .foregroundStyle(Color.foreground)
                        }.padding(.leading, 10)
                        Spacer()
                    }.padding(.bottom, 5)
                }
            case 1:
                VStack(spacing: 2) {
                    Rectangle()
                        .frame(width: 30, height: 10)
                        .foregroundStyle(Color.foreground)
                        .padding(.top)
                    
                    HStack {
                        VStack(spacing: 2) {
                            Rectangle()
                                .frame(width: 50, height: 10)
                                .foregroundStyle(Color.foreground)
                            Rectangle()
                                .frame(width: 50, height: 10)
                                .foregroundStyle(Color.foreground)
                        }.padding(.leading, 10)
                        Spacer()
                    }.padding(.top, 5)
                }
            case 3:
                VStack(spacing: 2) {
                    Rectangle()
                        .frame(width: 10, height: 20)
                        .foregroundStyle(Color.foreground)
                        .padding(.vertical)
                    Rectangle()
                        .frame(width: 45, height: 10)
                        .foregroundStyle(Color.foreground)
                    Rectangle()
                        .frame(width: 60, height: 10)
                        .foregroundStyle(Color.foreground)
                        .padding(.bottom, 5)
                }
            case 2:
                VStack(spacing: 2) {
                    Rectangle()
                        .frame(width: 30, height: 10)
                        .foregroundStyle(Color.foreground)
                        .padding(.vertical)
                    
                    VStack(spacing: 2) {
                        Rectangle()
                            .frame(width: 45, height: 10)
                            .foregroundStyle(Color.foreground)
                        Rectangle()
                            .frame(width: 60, height: 10)
                            .foregroundStyle(Color.foreground)
                    }.padding(.bottom, 5)
                }
            default:
                EmptyView()
            }
        }
        .frame(width: 85, height: 85)
        .background {
            Color.Background.primary
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    EventSharingTemplateView(template: 2)
}
