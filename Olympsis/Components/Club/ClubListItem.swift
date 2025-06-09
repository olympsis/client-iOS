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
    @State var showActions: Bool = true
    @State private var showEULA: Bool = false
    @State private var showDetails: Bool = false
    @State private var status: LOADING_STATE = .pending
    
    @Environment(SessionStore.self) private var session
    
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
            ClubListItemMedia(club: club)
                
            HStack {
                VStack(alignment:.leading){
                    Text(clubName)
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color("foreground"))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                        Text("\(club.city), ").foregroundColor(.gray).font(.callout)
                        +
                        Text(club.state)
                            .foregroundColor(.gray)
                            .font(.callout)
                    }
                }
                .padding(.leading, 5)
            }
            .padding(.all)
            
            HStack {
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .lineLimit(3)
                    .font(.callout)
            }
            .padding(.bottom)
            
            if showActions {
                HStack(spacing: 15) {
                    Button(action: { self.showDetails.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 35)
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
                        LoadingButton(text: "Apply", height: 35, status: $status)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding([.horizontal, .bottom])
            }
        }
        .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(Color.Background.secondary))
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
        .environment(SessionStore())
}
