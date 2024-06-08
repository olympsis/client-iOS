//
//  ImageLoading.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/7/24.
//

import SwiftUI

struct ImageLoadingView: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(.gray)
            .overlay {
                ProgressView()
            }
    }
}

#Preview {
    ImageLoadingView()
}
