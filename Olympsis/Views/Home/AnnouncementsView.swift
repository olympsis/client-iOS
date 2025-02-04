//
//  AnnouncementsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//

import SwiftUI

struct AnnouncementsView: View {
    
    @State var index = "0"
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        VStack(alignment: .leading){
            Text(String(localized: "Announcements", table: "General"))
                .font(.custom("Helvetica Neue", size: 17))
                .bold()
                .padding(.horizontal)
            
            VStack {
                TabView(selection: $index){
                    ForEach(session.feedObserver.announcements){ announcement in
                        AnnouncementView(announcement: announcement).tag(announcement.id)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
                
                HStack(spacing: 2) {
                    ForEach(session.feedObserver.announcements, id: \.id) { index in
                        Rectangle()
                            .fill(index.id == self.index ? Color("color-prime") : Color("color-prime").opacity(0.5))
                            .frame(width: 30, height: 5)
                    }
                }.padding()
            }
            .onChange(of: session.feedObserver.announcements) { _, _ in
                if !session.feedObserver.announcements.isEmpty {
                    self.index = session.feedObserver.announcements[0].id
                }
            }
        }
        .padding(.top)
    }
}

#Preview {
    AnnouncementsView()
        .environmentObject(SessionStore())
}
