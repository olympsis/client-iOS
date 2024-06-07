//
//  FullImageViewer.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/6/24.
//

import SwiftUI
import Kingfisher

struct FullImageViewer: View {
    
    @State var imageURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let url = imageURL {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
            }
        }.onTapGesture {
            dismiss()
        }
    }
}

#Preview {
    FullImageViewer(imageURL: generateImageURL("event-images/soccer-0.jpg"))
}
