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
                Text("Badges")
                    .font(.title)
                    .bold()
                    .padding(.leading, 25)
                Rectangle()
                    .frame(height: 1)
                    .padding(.trailing, 25)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .center){
                    Text("No Badges")
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
