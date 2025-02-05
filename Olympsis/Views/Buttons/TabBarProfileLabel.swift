//
//  TabBarProfileButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/30/24.
//

import SwiftUI
import Kingfisher

struct TabBarProfileLabel: View {
    
    @Binding var currentTab: Tab
    @State private var imageFailed: Bool = false
    @Environment(SessionStore.self) private var session
    
    var imageURL: URL? {
        guard let user = session.user,
              let imageURL = user.imageURL else {
            return nil
        }
        return generateImageURL(imageURL)
    }
    
    var body: some View {
        KFImage(imageURL)
            .placeholder({
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    .overlay {
                        ProgressView()
                    }
            })
            .onFailure { _ in
                imageFailed = true
            }
            .cacheOriginalImage()
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 200)))
            .resizable()
            .overlay {
                if imageFailed {
                    if currentTab == .profile {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(Color.dark)
                            }
                    } else {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.dark)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(.white)
                            }
                            .overlay {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            }
                    }
                }
            }
            .clipShape(Circle())
            .frame(width: 20, height: 20)
    }
}

#Preview {
    return ZStack {
        Rectangle()
            .foregroundStyle(Color.dark)
            .frame(width: 40, height: 40)
        TabBarProfileLabel(currentTab: .constant(.home))
            .environment(SessionStore())
    }
}
