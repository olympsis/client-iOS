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
    
    var clubName: String {
        guard let name = club.name else {
            return ""
        }
        return name
    }
    
    var imageURL: String {
        guard let img = club.imageURL else {
            return ""
        }
        return GenerateImageURL(img)
    }
    
    var description: String {
        guard let str = club.description else {
            return ""
        }
        return str
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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color("background"))
            
            VStack (alignment: .leading){
                HStack {
                    // IMAGE
                    AsyncImage(url: URL(string: imageURL)){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(5)
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipped()
                                    .cornerRadius(20)
                            } else if phase.error != nil {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("label"), lineWidth: 1.0)
                                        .frame(width: 100, height: 100)
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .opacity(0.1)
                                        .frame(width: 100, height: 100)
                                        .accentColor(Color("label"))
                                    ProgressView()
                                }
                            }
                    }.frame(width: 100, height: 100, alignment: .center)
                    
                    VStack(alignment:.leading){
                        Text(clubName)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color("label"))
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                        Text("\(club.city!), ").foregroundColor(.gray)
                        +
                        Text(club.state!)
                            .foregroundColor(.gray)
                        HStack {
                            if club.members!.count > 1 {
                                Text("\(club.members!.count) members")
                                    .foregroundColor(Color("label"))
                                    .font(.caption)
                            } else {
                                Text("\(club.members!.count) member")
                                    .foregroundColor(Color("label"))
                                    .font(.caption)
                            }
                            Spacer()
                            Text(getSportIcon(sport: club.sport!))
                        }
                    }.padding(.leading, 5)
                }.padding(.all)
                
                HStack {
                    Text(description)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .lineLimit(nil)
                }
                    
                VStack {
                    Button(action:{ Task{ await Apply() } }) {
                        LoadingButton(text: "Apply", width: SCREEN_WIDTH-100, status: $status)
                            .padding(.all)
                            .frame(maxWidth: .infinity)
                    }.contentShape(Rectangle())
                }.padding(.all)
            }
        }.padding(.horizontal, 5)
    }
}

struct SmallClubView_Previews: PreviewProvider {
    static var previews: some View {
        SmallClubView(club: CLUBS[0], showToast: .constant(false), observer: ClubObserver())
    }
}
