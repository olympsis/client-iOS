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
    
    @State var club: Club
    @Binding var showToast: Bool
    @ObservedObject var observer: ClubObserver
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.primary)
                    .opacity(0.1)
                    .frame(width: SCREEN_WIDTH-20, height: 240)
                VStack {
                    AsyncImage(url: URL(string: club.imageURL)){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .fixedSize()
                                    .frame(width: SCREEN_WIDTH-40, height: 100, alignment: .center)
                                    .cornerRadius(5)
                                    .clipped()
                                    
                            } else if phase.error != nil {
                                Color.red // Indicates an error.
                                    .cornerRadius(5)
                                    .frame(width: SCREEN_WIDTH-40, height: 100, alignment: .center)
                            } else {
                                Color.gray // Acts as a placeholder.
                                    .cornerRadius(5)
                                    .frame(width: SCREEN_WIDTH-40, height: 100, alignment: .center)
                            }
                    }.frame(width: SCREEN_WIDTH-20, height: 100, alignment: .center)
                    HStack {
                        VStack(alignment:.leading){
                            Text(club.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(.primary)
                                .opacity(0.7)
                            Text("\(club.city), ") + Text(club.state)
                            Spacer()
                            
                            

                            if club.isPrivate {
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
                            
                            if club.members.count > 1 {
                                Text("\(club.members.count) members")
                                    .opacity(0.5)
                                    .foregroundColor(.primary)
                            } else {
                                Text("\(club.members.count) member")
                                    .opacity(0.7)
                                    .foregroundColor(.primary)
                            }

                        }
                            .padding(.leading)
                        Spacer()
                        VStack(alignment: .trailing){
                            Text(getSportIcon(sport: club.sport))
                                .font(.largeTitle)
                                .padding(.trailing)
                            Spacer()
                            Button(action:{Task{
                                let res = await observer.createClubApplication(clubId:club.id)
                                if res {
                                    self.showToast = true
                                }
                            }}) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color("primary-color"))
                                        .frame(width: 100, height: 40)
                                    Text("apply")
                                        .foregroundColor(.white)
                                }
                            }.padding(.trailing)
                        }
                    }
                }.frame(height: 220)
            }
        }
    }
}

struct SmallClubView_Previews: PreviewProvider {
    static var previews: some View {
        SmallClubView(club: Club(id: "", name: "Provo Soccer", description: "Come play soccer with us.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/fields/1309-22-3679.jpg", isPrivate: false, isVisible: true, members: [Member](), rules: ["Don't steal", "No Fighting"]), showToast: .constant(false), observer: ClubObserver())
    }
}
