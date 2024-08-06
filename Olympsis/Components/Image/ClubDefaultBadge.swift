//
//  ClubDefaultBadge.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/7/24.
//

import SwiftUI

struct ClubDefaultBadge: View {
    var body: some View {
        Circle()
            .foregroundStyle(Color("background"))
            .frame(width: 35, height: 35)
            .overlay {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(Color.foreground)
                    .imageScale(.small)
            }
    }
}

#Preview {
    ClubDefaultBadge()
}
