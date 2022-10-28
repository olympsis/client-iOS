//
//  Home.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Home: View {
    
    @State private var index = "0";
    @StateObject private var observer = FeedObserver()
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HStack {
                        VStack(alignment: .leading){
                            Text("Welcome back \(session.getFirstName())")
                                .font(.custom("Helvetica Neue", size: 25))
                                .fontWeight(.regular)
                            Text("ready to play?")
                                .font(.custom("Helvetica Neue", size: 20))
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                        }.padding(.leading)
                            .padding(.top, 25)
                        Spacer()
                    }
                    Spacer()
                    
                    //MARK: - Announcements
                    HStack{
                        VStack(alignment: .leading){
                            Text("Announcements")
                                .font(.custom("Helvetica Neue", size: 17))
                                .bold()
                                .padding()
                            VStack {
                                TabView(selection: $index){
                                    ForEach(observer.announcements){ announcement in
                                        AnnouncementView(announcement: announcement).tag(announcement.id)
                                    }
                                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                    .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2, alignment: .center)
                                
                                // Page View Indicator
                                VStack{
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(observer.announcements, id: \.id) { index in
                                            Rectangle()
                                                .fill(index.id == self.index ? Color("primary-color") : Color("primary-color").opacity(0.5))
                                                .frame(width: 30, height: 5)
                                        }
                                    }.padding()
                                }
                            }.onChange(of: observer.announcements, perform: { newValue in
                                if !observer.announcements.isEmpty{
                                    self.index = observer.announcements[0].id
                                }
                            })
                        }
                    }
                    
                    //MARK: - Nearby Fields
                }.navigationTitle("Home")
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(SessionStore())
    }
}
