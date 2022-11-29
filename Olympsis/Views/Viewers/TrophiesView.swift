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
                Text("Trophies")
                    .font(.custom("ITCAvantGardeStd-Bold", size: 25, relativeTo: .largeTitle))
                    .bold()
                    .padding(.leading, 25)
                Rectangle()
                    .frame(height: 1)
                    .padding(.trailing, 25)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .center){
                    Text("No Trophies")
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
