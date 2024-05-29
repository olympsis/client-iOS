//
//  ClubTagView.swift
//  Olympsis
//
//  Created by Joel on 11/19/23.
//

import SwiftUI

struct ClubTag: View {
    
    @State var isSport: Bool
    @State var tagName: String
    
    var body: some View {
        if (isSport) {
            Text(tagName.prefix(1).capitalized + tagName.dropFirst())
                .foregroundStyle(Color("background"))
                .padding(.horizontal)
                .frame(height: 25)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color("foreground"))
                }
        } else {
            Text(tagName.prefix(1).capitalized + tagName.dropFirst())
                .foregroundStyle(Color("foreground"))
                .padding(.horizontal)
                .frame(height: 25)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(Color("foreground"))
                }
        }
    }
}

#Preview {
    ClubTag(isSport: true, tagName: "Soccer")
}
