//
//  ClubsList2.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/15/23.
//

import SwiftUI

struct ClubsList2: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack {
                ClubsList()
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("color-prime"))
                    }
                }
            }
            .navigationTitle("Clubs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ClubsList2_Previews: PreviewProvider {
    static var previews: some View {
        ClubsList2()
            .environmentObject(SessionStore())
    }
}
