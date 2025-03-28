//
//  Awards.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI

struct Awards: View {
    var body: some View {
        VStack {
            BadgesView()
                .padding(.top)
            
            TrophiesView()
        }
    }
}

#Preview {
    Awards()
}
