//
//  ImageFailed.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/7/24.
//

import SwiftUI

struct ImageLoadingFailedView: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(.gray)
            .overlay {
                Image(systemName: "rectangle.slash")
                    .foregroundStyle(Color("background"))
            }
    }
}

#Preview {
    ImageLoadingFailedView()
}
