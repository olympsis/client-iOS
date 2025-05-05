//
//  GroupBadgeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI
import Kingfisher

struct GroupBadgeView: View {
    
    var size: BADGE_SIZE
    var type: GROUP_TYPE
    var imageURL: URL?
    @State private var imageFailed: Bool = false
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        switch size {
        case .small:
            KFImage(imageURL)
                .placeholder({
                    Circle()
                        .frame(width: 35, height: 35)
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
                        Circle()
                            .frame(width: 35, height: 35)
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .overlay {
                                switch type {
                                case .Club:
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .frame(width: 18, height: 13)
                                        .foregroundStyle(Color.Brand.primary)
                                case .Organization:
                                    Image(systemName: "building.fill")
                                        .resizable()
                                        .frame(width: 10, height: 18)
                                        .foregroundStyle(Color.foreground)
                                }
                            }
                    }
                }
                .clipShape(Circle())
                .frame(width: 35, height: 35)
        case .medium:
            KFImage(imageURL)
                .placeholder({
                    Circle()
                        .frame(width: 65, height: 65)
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
                        Circle()
                            .frame(width: 65, height: 65)
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .overlay {
                                switch type {
                                case .Club:
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .frame(width: 30, height: 20)
                                        .foregroundStyle(Color.Brand.primary)
                                case .Organization:
                                    Image(systemName: "building.fill")
                                        .resizable()
                                        .frame(width: 20, height: 30)
                                        .foregroundStyle(Color.foreground)
                                }
                            }
                    }
                }
                .clipShape(Circle())
                .frame(width: 65, height: 65)
        case .large:
            KFImage(imageURL)
                .placeholder({
                    Circle()
                        .frame(width: 100, height: 100)
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
                        Circle()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .overlay {
                                switch type {
                                case .Club:
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .frame(width: 50, height: 35)
                                        .foregroundStyle(Color.Brand.primary)
                                case .Organization:
                                    Image(systemName: "building.fill")
                                        .resizable()
                                        .frame(width: 35, height: 50)
                                        .foregroundStyle(Color.foreground)
                                }
                            }
                    }
                }
                .clipShape(Circle())
                .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    GroupBadgeView(size: .large, type: .Club)
        .environment(SessionStore())
}
