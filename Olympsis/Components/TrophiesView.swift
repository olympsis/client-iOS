//
//  TrophiesView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct TrophiesView: View {
    var body: some View {
        VStack {
            HStack {
                Text(String(localized: "trophies", table: "Profile"))
                    .font(.title)
                    .bold()
                    .padding(.leading, 25)
                
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .center){
                    Text(String(localized: "no-trophies", table: "Profile"))
                }.frame(width: SCREEN_WIDTH)
            }
            Spacer()
        }.frame(minHeight: 200)
    }
}

struct TrophiesView_Previews: PreviewProvider {
    static var previews: some View {
        TrophiesView()
    }
}
