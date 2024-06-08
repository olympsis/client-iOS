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
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: "person.2")
                    .foregroundStyle(Color("foreground"))
                    .imageScale(.medium)
            }
    }
}

#Preview {
    ClubDefaultBadge()
}
