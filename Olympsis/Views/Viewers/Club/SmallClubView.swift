//
//  SmallClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI


struct SmallClubView: View {
    
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
    @State private var status: LOADING_STATE = .pending
    @State var club: Club
    @Binding var showToast: Bool
    @ObservedObject var observer: ClubObserver
    
    func Apply() async {
        status = .loading
        let res = await observer.createClubApplication(clubId:club.id!)
        if res {
            self.showToast = true
            status = .success
        }
    }
    
    var body: some View {
        VStack {
            ZStack (alignment: .bottom){
                AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (club.imageURL ?? ""))){ phase in
                    if let image = phase.image {
                        image // Displays the loaded image.
                            .fixedSize()
                            .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                            .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                            .clipped()
                        
                    } else if phase.error != nil {
                        ZStack {
                            Color.gray // Indicates an error.
                                .opacity(0.3)
                                .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                            Image(systemName: "exclamationmark.circle")
                        }
                    } else {
                        ZStack {
                            Color.gray // Acts as a placeholder.
                                .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
                            ProgressView()
                        }
                    }
                }.frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                
                ZStack {
                    Rectangle()
                        .cornerRadius(radius: 10, corners: [.bottomLeft, .bottomRight])
                        .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                    HStack {
                        VStack(alignment:.leading){
                            Text(club.name!)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                                .opacity(0.7)
                            Text("\(club.city!), ") + Text(club.state!)
                            Spacer()

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
                        .padding(.leading)
                        Spacer()
                        VStack(alignment: .trailing){
                            Text(getSportIcon(sport: club.sport!))
                                .font(.largeTitle)
                                .padding(.trailing)
                            Spacer()
                            Button(action:{ Task{ await Apply() } }) {
                                LoadingButton(text: "Apply", width: 100, status: $status)
                                    .padding(.trailing)
                            }
                        }
                    }.padding(.bottom)
                        .padding(.top)
                }.frame(width: SCREEN_WIDTH-20, height: 100)
            }
        }
    }
}

struct SmallClubView_Previews: PreviewProvider {
    static var previews: some View {
        SmallClubView(club: CLUBS[0], showToast: .constant(false), observer: ClubObserver())
    }
}
