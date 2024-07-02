//
//  SmallClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI


struct ClubListItem: View {
    
    var club: Club
    @Binding var showToast: Bool
    
    @State private var showEULA: Bool = false
    @State private var showDetails: Bool = false
    @State private var status: LOADING_STATE = .pending
    
    @EnvironmentObject private var session: SessionStore
    
    var clubName: String {
        return club.name
    }
    
    var description: String {
        guard let str = club.description else {
            return ""
        }
        return str
    }
    
    var sports: [String] {
        return club.sports
    }
    
    var acceptedEULA: Bool {
        guard let user = session.user,
              let hasAccepted = user.acceptedEULA else {
            return false
        }
        return hasAccepted
    }
    
    func Apply() async {
        
        // You need to have accepted EULA before joining a group
        guard acceptedEULA else {
            self.showEULA.toggle()
            return
        }
        
        status = .loading
        let res = await session.clubObserver.createClubApplication(clubId: club.id)
        if res {
            status = .success
        } else {
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                status = .pending
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                
                ClubLogo(club: club)
                
                VStack(alignment:.leading){
                    Text(clubName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("foreground"))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    Text("\(club.city), ").foregroundColor(.gray)
                    +
                    Text(club.state)
                        .foregroundColor(.gray)
                    HStack {
                        if club.members.count > 1 {
                            Text("\(club.members.count) members")
                                .foregroundColor(Color("foreground"))
                                .font(.caption)
                        } else {
                            Text("\(club.members.count) member")
                                .foregroundColor(Color("foreground"))
                                .font(.caption)
                        }
                    }
                }
                .padding(.leading, 5)
            }
            .padding(.all)
            
            HStack {
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .lineLimit(nil)
                    .font(.callout)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(sports, id: \.self) { sport in
                        ClubTag(isSport: true, tagName: sport)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack(spacing: 15) {
                Button(action: { self.showDetails.toggle() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: (SCREEN_WIDTH/2)-25,height: 35)
                            .foregroundStyle(.gray)
                            .opacity(0.5)
                        Text("Details")
                            .textCase(.uppercase)
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }.contentShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
                Button(action:{ Task{ await Apply() } }) {
                    LoadingButton(text: "Apply", width: (SCREEN_WIDTH/2)-25, height: 35, status: $status)
                }.contentShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.all)
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("background"))
                .padding(.horizontal, 5)
        }
        .fullScreenCover(isPresented: $showDetails, content: {
            ClubDetailView(club: club)
        })
        .sheet(isPresented: $showEULA, content: {
            EndUserLicenseAgreement()
        })
    }
}

#Preview {
    ClubListItem(club: CLUBS[0], showToast: .constant(false))
        .environmentObject(SessionStore())
}
