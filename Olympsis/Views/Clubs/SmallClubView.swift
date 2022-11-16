//
//  SmallClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI

struct SmallClubView: View {
    @State var club: Club
    @ObservedObject var observer: ClubObserver
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: club.imageURL)){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .cornerRadius(5)
                                .frame(width: 100, height: 100, alignment: .center)
                        } else if phase.error != nil {
                            Color.red // Indicates an error.
                                .cornerRadius(5)
                        } else {
                            Color.gray // Acts as a placeholder.
                                .cornerRadius(5)
                        }
                }.frame(width: 100, height: 100, alignment: .center)
                    .padding(.leading)
                
                VStack(alignment:.leading){
                    Text(club.name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                        .opacity(0.7)
                    Text(club.city)
                        .font(.headline)
                        .opacity(0.6)
                        .foregroundColor(.primary)
                    
                    if club.members.count > 1 {
                        Text("\(club.members.count) members")
                            .opacity(0.5)
                            .foregroundColor(.primary)
                    } else {
                        Text("\(club.members.count) member")
                            .opacity(0.7)
                            .foregroundColor(.primary)
                    }
                    

                    if club.isPrivate {
                        VStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 60)
                                    .foregroundColor(Color("primary-color"))
                                .cornerRadius(5)
                                Text("Private")
                                    .foregroundColor(.white)
                            }
                        }.padding(.bottom, 3)
                        
                    } else {
                        VStack {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color("primary-color"))
                                    .frame(width: 60)
                                .cornerRadius(5)
                                Text("Public")
                                    .foregroundColor(.white)
                            }
                        }.padding(.bottom, 3)
                        
                    }

                }.frame(height: 90)
                Spacer()
                VStack {
                    Spacer()
                    Button(action:{Task{
                        let res = await observer.createClubApplication(clubId:club.id)
                        print(res)
                    }}) {
                        Image(systemName: "note.text")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.primary)
                            .padding(.trailing)
                            .opacity(0.8)
                    }
                    Text("apply")
                        .padding(.trailing)
                        .font(.callout)
                }
            }
        }.frame(height: 100)
    }
}

struct SmallClubView_Previews: PreviewProvider {
    static var previews: some View {
        SmallClubView(club: Club(owner: "", name: "Provo Soccer", description: "Come play soccer with us.", isPrivate: false, location: GeoJSON(type: "Point", coordinates: ["40.249480", "-111.655317"]), city: "Provo", state: "Utah", country: "United States of America", imageURL: "https://storage.googleapis.com/olympsis-1/fields/1309-22-3679.jpg", members: [Member](), rules: ["Don't steal", "No Fighting"], createdAt: ""), observer: ClubObserver())
    }
}
