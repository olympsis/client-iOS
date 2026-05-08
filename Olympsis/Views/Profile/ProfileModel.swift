//
//  ProfileModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI
import Kingfisher

struct ProfileModel: View {

    @State private var imageFailed: Bool = false
    /// Controls the full-screen image viewer that appears when the user
    /// taps their avatar. Lives here (vs. the parent) so the tap stays
    /// local to the badge.
    @State private var showFullImage = false
    @Environment(SessionStore.self) private var session

    var imageURL: URL? {
        guard let user = session.user,
              let image = user.imageURL else {
            return nil
        }
        return generateImageURL(image)
    }
    
    var firstName: String {
        guard let user = session.user,
              let name = user.firstName else {
            return "Olympsis"
        }
        return name
    }
    
    var lastName: String {
        guard let user = session.user,
              let name = user.lastName else {
            return "User"
        }
        return name
    }
    
    var bio: String {
        guard let user = session.user,
              let bio = user.bio else {
            return ""
        }
        return bio
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                UserBadgeView(size: .large, imageURL: imageURL)
                    .onTapGesture { showFullImage = true }

                VStack(alignment: .leading){
                    HStack(){
                        Text(firstName)
                            .font(.system(size: 30))
                            .fontWeight(.black)
                        Text(lastName)
                            .font(.system(size: 30))
                            .fontWeight(.black)
                    }.frame(height: 30)
                }.padding(.leading)
            }
            Text(bio)
                .padding(.top)
                .padding(.bottom)
        }
        .fullScreenCover(isPresented: $showFullImage) {
            FullScreenProfileImage(imageURL: imageURL) {
                showFullImage = false
            }
            // Clear background so the cover can fade in / out alongside
            // the inner scale animation instead of revealing the
            // system's opaque container.
            .presentationBackground(.clear)
        }
        // Suppress the system's slide-up animation for the cover —
        // we want the inner scale-from-nothing animation to be the
        // whole effect. Both presentation and dismissal hit this path.
        .transaction(value: showFullImage) { transaction in
            transaction.disablesAnimations = true
        }
    }
}

/// Full-screen profile image viewer. Scales out from a point on
/// appearance, scales back on dismiss, and offers a chevron-left
/// close button. The image keeps its circular crop so the transition
/// reads as the same avatar growing from the badge.
private struct FullScreenProfileImage: View {

    let imageURL: URL?
    let onClose: () -> Void

    /// Drives the scale + opacity animation. We don't use SwiftUI's
    /// transition system because `fullScreenCover`'s container does
    /// its own thing; controlling the animation manually with a
    /// `@State` flag we toggle from `onAppear` / `onClose` is more
    /// predictable.
    @State private var animateIn = false

    private var animation: Animation {
        .spring(response: 0.42, dampingFraction: 0.82)
    }

    var body: some View {
        ZStack {
            // Backdrop. Fades in with `animateIn` so the user doesn't
            // see a jarring full-black flash before the image scales.
            Color.black
                .opacity(animateIn ? 0.92 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            KFImage(imageURL)
                .placeholder {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay { ProgressView() }
                }
                .resizable()
                .cacheOriginalImage()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 1200, height: 1200)))
                .scaledToFill()
                // Square frame keeps the circle clip uniform regardless
                // of source aspect ratio.
                .frame(width: imageSide, height: imageSide)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .scaleEffect(animateIn ? 1.0 : 0.05)
                .opacity(animateIn ? 1 : 0)
        }
        .overlay(alignment: .topLeading) {
            Group {
                if #available(iOS 26.0, *) {
                    Button(action: dismiss) {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(12)
                    }
                    .glassEffect(.regular.interactive(), in: .circle)
                } else {
                    Button(action: dismiss) {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .opacity(animateIn ? 1 : 0)
        }
        .onAppear {
            // Kick the animation on the next runloop tick so the
            // initial render is at scale 0.05, then springs to 1.
            // Without the slight defer, SwiftUI sometimes collapses
            // the state change into the same frame and the animation
            // is skipped.
            DispatchQueue.main.async {
                withAnimation(animation) { animateIn = true }
            }
        }
    }

    private var imageSide: CGFloat {
        // Nice big avatar that scales with screen width but caps so
        // it doesn't dominate landscape / iPad layouts.
        min(UIScreen.main.bounds.width - 60, 420)
    }

    private func dismiss() {
        withAnimation(animation) { animateIn = false }
        // Wait for the spring to finish before dismissing the cover —
        // dismissing immediately would cut the scale-out animation
        // short.
        Task {
            try? await Task.sleep(nanoseconds: 380_000_000) // ~ animation duration
            onClose()
        }
    }
}

#Preview {
    ProfileModel()
        .environment(SessionStore())
}
