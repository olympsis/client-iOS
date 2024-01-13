//
//  ClubTagView.swift
//  Olympsis
//
//  Created by Joel on 11/19/23.
//

import SwiftUI

struct ClubTagView: View {
    
    @State var isSport: Bool
    @State var tagName: String
    
    var body: some View {
        if (isSport) {
            Text(tagName.prefix(1).capitalized + tagName.dropFirst())
                .foregroundStyle(Color("background"))
                .padding(.horizontal)
                .frame(height: 30)
                .background {
                    Rectangle()
                        .foregroundStyle(Color("foreground"))
                }
        } else {
            Text(tagName.prefix(1).capitalized + tagName.dropFirst())
                .foregroundStyle(Color("foreground"))
                .padding(.horizontal)
                .frame(height: 30)
                .background {
                    Rectangle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color("foreground"))
                }
        }
    }
}

#Preview {
    ClubTagView(isSport: true, tagName: "Soccer")
}
