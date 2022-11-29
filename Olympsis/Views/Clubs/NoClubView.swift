//
//  NoClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI
import AlertToast

struct NoClubView: View {
    @State var isLoading = true
    
    @State var index                            = 0
    @State var text: String                     = ""
    @State var showNewClubCover                 = false
    @State var showCompletedApplicationToast    = false
    
    @StateObject private var clubObserver = ClubObserver()
    
    @EnvironmentObject var session: SessionStore
    var body: some View {
        VStack {
            SearchBar(text: $text)
                .frame(width: SCREEN_WIDTH - 25)
            if clubObserver.isLoading {
                ProgressView()
            } else {
                ScrollView(.vertical, showsIndicators: false){
                    HStack{
                        if text != ""{
                            ForEach(clubObserver.clubs.filter{$0.name.lowercased().contains(text.lowercased())}, id: \.id){ c in
                                SmallClubView(club: c, showToast: $showCompletedApplicationToast, observer: clubObserver)
                            }
                        } else {
                            ForEach(clubObserver.clubs, id: \.id){ c in
                                SmallClubView(club: c, showToast: $showCompletedApplicationToast, observer: clubObserver)

                            }
                        }
                    }
                }.toast(isPresenting: $showCompletedApplicationToast){
                    AlertToast(displayMode: .banner(.pop), type: .regular, title: "Application Sent!", style: .style(titleColor: .green, titleFont: .body))
                }
            }
        }.task {
            if session.clubs.isEmpty {
                await clubObserver.getClubs()
                session.clubs = clubObserver.clubs
                clubObserver.isLoading = false
            }
        }
        .fullScreenCover(isPresented: $showNewClubCover) {
            CreateNewClub()
        }
    }
}

struct NoClubView_Previews: PreviewProvider {
    static var previews: some View {
        NoClubView()
    }
}
