//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/1/24.
//

import SwiftUI
import Kingfisher

struct ClubView: View {
    
    @State private var showMenu = false
    @State private var showEULA = false
    @State private var showNewPost = false
    @State private var showNewEvent = false
    @State private var showSelector = false
    @State private var state: LOADING_STATE = .pending
    
    @StateObject private var club: Club
    @EnvironmentObject private var session: SessionStore
    
    init(club: Club) {
        self._club = StateObject(wrappedValue: club)
    }
    
    var acceptedEULA: Bool {
        guard let user = session.user,
              let hasAccepted = user.acceptedEULA else {
            return false
        }
        return hasAccepted
    }
    
    var body: some View {
        NavigationStack {
            GroupFeed(showNewPost: $showNewPost, showNewEvent: $showNewEvent)
                .sheet(isPresented: $showSelector, content: {
                    GroupSelector()
                        .presentationDetents([.medium])
                })
                .sheet(isPresented: $showEULA, content: {
                    EndUserLicenseAgreement()
                })
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(alignment: .center) {
                            Text(club.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                           Image(systemName: "chevron.down")
                                .imageScale(.small)
                            Spacer()
                        }
                        .frame(width: SCREEN_WIDTH/2, alignment: .leading)
                        .onTapGesture {
                            self.showSelector.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(action: {
                                // You need to have accepted EULA before being able to make a post
                                guard acceptedEULA else {
                                    self.showEULA.toggle()
                                    return
                                }
                                self.showNewPost.toggle()
                            }) {
                                Text("New Post")
                            }
                            Button(action: { self.showNewEvent.toggle() }) {
                                Text("New Event")
                            }
                        } label: {
                            Image(systemName: "plus.square.dashed")
                                .foregroundStyle(Color.foreground)
                                .imageScale(.large)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: GroupMessages()) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .foregroundStyle(Color.foreground)
                                .imageScale(.large)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            ClubMenu()
                                .environmentObject(club)
                                .environmentObject(session)
                        } label: {
                            if let logo = club.logo,
                               let url = generateImageURL(logo) {
                                KFImage(url)
                                    .placeholder({
                                        GroupBadgeLoadingView()
                                    })
                                    .resizable()
                                    .cacheOriginalImage()
                                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 80, height: 80)))
                                    .frame(width: 35, height: 35)
                                    .scaledToFill()
                                    .clipped()
                                    .clipShape(Circle())
                            } else {
                                ClubDefaultBadge()
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    ClubView(club: CLUBS[0])
        .environmentObject(SessionStore())
}
