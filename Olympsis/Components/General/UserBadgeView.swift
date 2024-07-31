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
    @State private var imageFailed: Bool = false
    @EnvironmentObject private var session: SessionStore
    
    private var imageURL: URL? {
        guard let user = session.user,
              let imageURL = user.imageURL else {
            return nil
        }
        return generateImageURL(imageURL)
    }
    
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
                            .foregroundStyle(Color.background)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundStyle(Color.foreground)
                            }
                            .overlay {
                                Circle()
                                    .stroke(Color.foreground, lineWidth: 2)
                                    .frame(width: 35, height: 35)
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
                            .foregroundStyle(Color.background)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.foreground)
                            }
                            .overlay {
                                Circle()
                                    .stroke(Color.foreground, lineWidth: 4)
                                    .frame(width: 65, height: 65)
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
                            .foregroundStyle(Color.background)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.foreground)
                            }
                            .overlay {
                                Circle()
                                    .stroke(Color.foreground, lineWidth: 5)
                                    .frame(width: 100, height: 100)
                            }
                    }
                }
                .clipShape(Circle())
                .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    UserBadgeView(size: .small)
        .environmentObject(SessionStore())
}
