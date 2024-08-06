//
//  RoomListItemTemplate.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/27/24.
//

import SwiftUI

struct RoomListItemTemplate: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 50)
                .foregroundColor(Color.background)
                .overlay(alignment: .center) {
                    Image(systemName: "rectangle.3.group.fill")
                        .foregroundStyle(Color.foreground)
                }
                .padding(.horizontal)
            
            Text("room.name")
                .font(.body)
                .lineLimit(1)
                .foregroundColor(Color.foreground)
            
            Spacer()
            LoadingButton(text: "Join", width: 100, status: .constant(.pending))
                .frame(width: 100)
                .padding(.trailing)
        }
        .redacted(reason: .placeholder)
    }
}

#Preview {
    RoomListItemTemplate()
}
