//
//  SmallClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI


struct SmallClubView: View {

    @State private var status: LOADING_STATE = .pending
    @State var club: Club
    @Binding var showToast: Bool
    @ObservedObject var observer: ClubObserver
    
    var imageURL: String {
        guard let img = club.imageURL else {
            return ""
        }
        return GenerateImageURL(img)
    }
    
    func Apply() async {
        status = .loading
        guard let id = club.id else {
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                status = .pending
            }
            return
        }
        let res = await observer.createClubApplication(clubId: id)
        if res {
            status = .success
        } else {
            status = .failure
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                status = .pending
            }
        }
    }
    
    func getSportIcon(sport: String) -> String {
        if sport == "soccer" {
            return "⚽️"
        } else if sport == "basketball"{
            return "🏀"
        } else if sport == "cricket"{
            return "🏏"
        } else if sport == "volleyball"{
            return "🏐"
        } else if sport == "tennis" {
            return "🎾"
        } else {
            return ""
        }
    }
    
    var description: String {
        guard let str = club.description else {
            return ""
        }
        return str
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
            VStack (alignment: .leading){
                HStack {
                    VStack(alignment:.leading){
                        Text(club.name!)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                            .opacity(0.7)
                        Text("\(club.city!), ") + Text(club.state!)
                        Spacer()
                    }
                    Spacer()
                    Text(getSportIcon(sport: club.sport!))
                        .padding(.trailing)
                }.padding(.horizontal)
                    .padding(.vertical)
                Text(description)
                    .padding(.horizontal)
                HStack {
                    VStack(alignment: .leading){
                        if club.visibility == "private" {
                            VStack {
                                Text("Private")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        } else {
                            VStack {
                                Text("Public")
                                    .foregroundColor(.green)
                            }
                        }
                        if club.members!.count > 1 {
                            Text("\(club.members!.count) members")
                                .opacity(0.5)
                                .foregroundColor(.primary)
                        } else {
                            Text("\(club.members!.count) member")
                                .opacity(0.7)
                                .foregroundColor(.primary)
                        }
                    }
                    Spacer()
                    Button(action:{ Task{ await Apply() } }) {
                        LoadingButton(text: "Apply", width: 100, status: $status)
                    }.contentShape(Rectangle())
                }.padding(.horizontal)
                    .padding(.vertical)
            }
        }.frame(height: 200)
    }
}

struct SmallClubView_Previews: PreviewProvider {
    static var previews: some View {
        SmallClubView(club: CLUBS[0], showToast: .constant(false), observer: ClubObserver())
    }
}
