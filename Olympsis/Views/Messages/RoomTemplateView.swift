//
//  RoomTemplate.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import SwiftUI

struct RoomTemplateView: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 50)
                .padding(.leading)
                .foregroundColor(.gray)
                .opacity(0.3)
            Rectangle()
                .frame(maxWidth: SCREEN_WIDTH, maxHeight: 15)
                .padding(.trailing)
                .foregroundColor(.gray)
                .opacity(0.3)

            Spacer()
        }
    }
}

struct RoomTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        RoomTemplateView()
    }
}
