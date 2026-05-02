//
//  BadgesView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct BadgesView: View {
    var body: some View {
        VStack {
            HStack {
                Text(String(localized: "badges", table: "Profile"))
                    .font(.title)
                    .bold()
                    .padding(.leading, 25)

                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .center){
                    Text(String(localized: "no-badges", table: "Profile"))
                }.frame(width: SCREEN_WIDTH)
            }
            Spacer()
        }.frame(minHeight: 200)
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
    }
}
