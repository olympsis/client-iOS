//
//  FriendRequestView.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/23/22.
//

import SwiftUI
/*
struct FriendRequestView: View {
    
    @State var request: FriendRequest
    @State var observer: UserObserver
    @Binding var requests: [FriendRequest]
    
    @EnvironmentObject private var session: SessionStore
    
    func Respond(status: String) async {
        let d = UpdateFriendRequestDao(_status: status)
        if status == "accepted"{
            do {
                let resp = try await observer.UpdateFriendRequest(id: request.id, dao: d)
                if let r = resp {
                    if var usr = session.user {
                        if var friends = usr.friends {
                            friends.append(r)
                        } else {
                            usr.friends = [r]
                        }
                    }
                }
                requests.removeAll(where: {$0.id == request.id})
            } catch {
                print(error)
            }
        } else {
            do {
                
                let _ = try await observer.UpdateFriendRequest(id: request.id, dao: d)
                requests.removeAll(where: {$0.id == request.id})
            } catch {
                print(error)
            }
        }
        
    }
    
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (request.requestorData.imageURL ?? ""))){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .clipShape(Circle())
                                .scaledToFill()
                                .clipped()
                        } else if phase.error != nil {
                            ZStack {
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.red)
                                Color.gray // Acts as a placeholder.
                                    .clipShape(Circle())
                                    .opacity(0.3)
                            }
                        } else {
                            ZStack {
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(Color("primary-color"))
                                Color.gray // Acts as a placeholder.
                                    .clipShape(Circle())
                                    .opacity(0.3)
                            }
                        }
                }.frame(width: 80, height: 80)
                    .padding(.trailing, 5)
                .padding(.leading)
                
                
                VStack(alignment: .leading) {
                    Text("\(request.requestorData.firstName) \(request.requestorData.lastName)")
                        .font(.headline)
                    Text("\(request.requestorData.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Button(action:{
                            Task {
                                await Respond(status: "accepted")
                            }
                        }){
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 100, height: 40)
                                    .foregroundColor(Color("primary-color"))
                                Text("Accept")
                                    .foregroundColor(.white)
                            }
                        }
                        Button(action:{
                            Task {
                                await Respond(status: "denied")
                            }
                        }){
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 100, height: 40)
                                    .foregroundColor(.secondary)
                                Text("Delete")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                Spacer()
            }
            
        }
    }
}

struct FriendRequestView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestView()
    }
}
*/
