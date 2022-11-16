//
//  Clubs.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Clubs: View {
    @State var index = 0
    @State var text: String = ""
    @StateObject private var clubObserver = ClubObserver()
    @EnvironmentObject var session: SessionStore
    var body: some View {
        NavigationView {
            if session.clubsId.isEmpty {
                VStack {
                    SearchBar(text: $text)
                        .frame(width: SCREEN_WIDTH - 25)
                    if clubObserver.isLoading {
                        ProgressView()
                    } else {
                        ScrollView(.vertical, showsIndicators: false){
                            HStack{
                                ForEach(clubObserver.clubs, id: \.id){ c in
                                    SmallClubView(club: c, observer: clubObserver)
                                        .frame(width: SCREEN_WIDTH, height: 110, alignment: .center)
                                }
                            }
                        }
                    }
                    Spacer()
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Clubs")
                            .font(.largeTitle)
                            .bold()
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "c.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.gray)
                    }
                }
                .task {
                    await clubObserver.fetchClubs()
                    session.clubs = clubObserver.clubs
                    clubObserver.isLoading = false
                }
                
            } else {
                VStack {
                    
                }.toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(clubObserver.clubs[index].name)
                            .font(.largeTitle)
                            .bold()
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "c.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.gray)
                    }
                }
            }

        }
    }
}

struct Clubs_Previews: PreviewProvider {
    static var previews: some View {
        Clubs().environmentObject(SessionStore())
    }
}
