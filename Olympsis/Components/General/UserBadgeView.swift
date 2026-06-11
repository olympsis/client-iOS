//
//  UserProfileView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/30/24.
//

import SwiftUI
import Kingfisher

struct UserBadgeView: View {
    
    var size: BADGE_SIZE
    var imageURL: URL?
    var color: Color = Color.Background.secondary
    @State private var imageFailed: Bool = false
    
    var body: some View {
        switch size {
        case .small:
            KFImage(imageURL)
                .placeholder({
                    Circle()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(color)
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
                            .foregroundStyle(color)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundStyle(Color.Foreground.default)
                            }
                    }
                }
                .clipShape(Circle())
                .frame(width: 35, height: 35)
                .overlay {
                    Circle()
                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                }
        case .medium:
            KFImage(imageURL)
                .placeholder({
                    Circle()
                        .frame(width: 65, height: 65)
                        .foregroundStyle(color)
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
                            .foregroundStyle(color)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.Foreground.default)
                            }
                    }
                }
                .clipShape(Circle())
                .frame(width: 65, height: 65)
                .overlay {
                    Circle()
                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                }
        case .large:
            KFImage(imageURL)
                .placeholder({
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(color)
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
                            .foregroundStyle(color)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.Foreground.default)
                            }
                    }
                }
                .clipShape(Circle())
                .frame(width: 100, height: 100)
                .overlay {
                    Circle()
                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                }
        }
    }
}

#Preview {
    UserBadgeView(size: .small)
}
