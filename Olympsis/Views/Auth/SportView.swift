//
//  SportView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/28/22.
//

import SwiftUI

struct SportView: View {
    @State var sport: String
    @State var isSelected: Bool = false
    var body: some View {
        HStack {
            Button(action:{self.isSelected.toggle()}){
                isSelected == true ? Image(systemName: "circle.fill")
                    .foregroundColor(Color("primary-color")).imageScale(.large) : Image(systemName:"circle")
                    .foregroundColor(.black).imageScale(.large)
            }
            Text(sport)
                .font(.custom("ITCAvantGardeStd-Bk", size: 20, relativeTo: .body))
            Spacer()
        }
    }
}

struct SportView_Previews: PreviewProvider {
    static var previews: some View {
        SportView(sport: "soccer")
    }
}
