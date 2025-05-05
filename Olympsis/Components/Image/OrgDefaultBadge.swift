//
//  OrgDefaultBadge.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/7/24.
//

import SwiftUI

struct OrgDefaultBadge: View {
    var body: some View {
        Circle()
            .foregroundStyle(Color(Color.Background.secondary))
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: "building")
                    .foregroundStyle(Color("foreground"))
                    .imageScale(.medium)
            }
    }
}

#Preview {
    OrgDefaultBadge()
}
