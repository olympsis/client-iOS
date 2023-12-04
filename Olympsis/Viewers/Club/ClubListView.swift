//
//  SmallClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI


struct ClubListView: View {

    @State private var status: LOADING_STATE = .pending
    @State private var showDetails: Bool = false
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
    
    var sport: String {
        guard let s = club.sport else {
            return "unknown"
        }
        return s
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
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                // IMAGE
                AsyncImage(url: URL(string: imageURL)){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipped()
                        } else if phase.error != nil {
                            ZStack {
                                Rectangle()
                                    .stroke(Color("foreground"), lineWidth: 1.0)
                                    .frame(width: 100, height: 100)
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .imageScale(.large)
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .opacity(0.1)
                                    .frame(width: 100, height: 100)
                                    .accentColor(Color("foreground"))
                                ProgressView()
                            }
                        }
                }.frame(width: 100, height: 100, alignment: .center)
                
                VStack(alignment:.leading){
                    Text(clubName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("foreground"))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    Text("\(club.city!), ").foregroundColor(.gray)
                    +
                    Text(club.state!)
                        .foregroundColor(.gray)
                    HStack {
                        if club.members!.count > 1 {
                            Text("\(club.members!.count) members")
                                .foregroundColor(Color("foreground"))
                                .font(.caption)
                        } else {
                            Text("\(club.members!.count) member")
                                .foregroundColor(Color("foreground"))
                                .font(.caption)
                        }
                    }
                }.padding(.leading, 5)
            }.padding(.all)
            
            HStack {
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .lineLimit(nil)
                    .font(.callout)
            }
            
            HStack {
                ClubTagView(isSport: true, tagName: sport)
            }.padding(.horizontal)
                .padding(.top)
            
            HStack(spacing: 15) {
                Button(action:{ Task{ await Apply() } }) {
                    LoadingButton(text: "Apply", width: SCREEN_WIDTH-100, status: $status)
                }.contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                Button(action: { self.showDetails.toggle() }) {
                    ZStack {
                        Rectangle()
                            .stroke(lineWidth: 1)
                            .frame(height: 40)
                        Text("Details")
                            .textCase(.uppercase)
                            .font(.caption)
                    }
                }.contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
            }.padding(.all)
        }.background {
            Rectangle()
                .foregroundColor(Color("background"))
                .padding(.horizontal, 5)
        }
        .fullScreenCover(isPresented: $showDetails, content: {
            ClubView(club: club)
        })
    }
}

#Preview {
    ClubListView(club: CLUBS[0], showToast: .constant(false), observer: ClubObserver())
}
