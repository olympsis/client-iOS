//
//  GroupBadgeLoadingView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/7/24.
//

import SwiftUI

struct GroupBadgeLoadingView: View {
    var body: some View {
        Circle()
            .foregroundStyle(.gray)
            .frame(width: 40, height: 40)
            .overlay {
                ProgressView()
            }
    }
}

#Preview {
    GroupBadgeLoadingView()
}
