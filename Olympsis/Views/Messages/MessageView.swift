//
//  MessageView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import SwiftUI

struct MessageView: View {
    
    @State var room: Room
    @State var data: UserPeek?
    @State var message: Message
    @State private var imageURL = ""
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        if let usr = session.user {
            if message.from == usr.uuid {
                HStack (alignment: .bottom){
                    Spacer()
                    VStack{
                        Text(message.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                    }.frame(alignment: .trailing)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("primary-color"))
                        }
                        .frame(maxWidth: SCREEN_WIDTH/1.4, alignment: .trailing)
                }.padding(.trailing, 10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                HStack (alignment: .bottom){
                    if let d = data {
                        if let img = d.imageURL {
                            VStack{
                                AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + img)){ phase in
                                    if let image = phase.image {
                                        image // Displays the loaded image.
                                            .resizable()
                                            .clipShape(Circle())
                                            .scaledToFill()
                                            .clipped()
                                    } else if phase.error != nil {
                                        Color.red // Indicates an error.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    } else {
                                        Color.gray // Acts as a placeholder.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    }
                                }.frame(width: 25, height: 25)
                            }
                        } else {
                            Circle()
                                .frame(width: 25)
                        }
                    } else {
                        Circle()
                            .frame(width: 25)
                    }
                    
                    
                    VStack(alignment: .leading) {
                        if let d = data {
                            Text(d.firstName + " " + d.lastName)
                                .font(.caption)
                                .frame(height: 3)
                                .padding(.leading, 5)
                        } else {
                            Text("Unknown User")
                                .font(.caption)
                                .frame(height: 3)
                                .padding(.leading, 5)
                        }
                        VStack {
                            Text(message.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }.frame(alignment: .leading)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                            .background{
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color("primary-color"))
                            }
                            .frame(maxWidth: SCREEN_WIDTH/1.4, alignment: .leading)
                            .task {
                                imageURL = room.members.first(where: {$0.uuid == message.from})?.uuid ?? "xxx"
                        }
                    }
                    
                    Spacer()
                }.padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            HStack (alignment: .bottom){
                if let d = data {
                    if let img = d.imageURL {
                        VStack{
                            AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + img)){ phase in
                                if let image = phase.image {
                                    image // Displays the loaded image.
                                        .resizable()
                                        .clipShape(Circle())
                                        .scaledToFill()
                                        .clipped()
                                } else if phase.error != nil {
                                    Color.red // Indicates an error.
                                        .clipShape(Circle())
                                        .opacity(0.3)
                                } else {
                                    Color.gray // Acts as a placeholder.
                                        .clipShape(Circle())
                                        .opacity(0.3)
                                }
                            }.frame(width: 25, height: 25)
                        }
                    } else {
                        Circle()
                            .frame(width: 25)
                    }
                } else {
                    Circle()
                        .frame(width: 25)
                }
                
                
                VStack(alignment: .leading) {
                    if let d = data {
                        Text(d.firstName + " " + d.lastName)
                            .font(.caption)
                            .frame(height: 3)
                            .padding(.leading, 5)
                    } else {
                        Text("Unknown User")
                            .font(.caption)
                            .frame(height: 3)
                            .padding(.leading, 5)
                    }
                    VStack {
                        Text(message.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }.frame(alignment: .leading)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("primary-color"))
                        }
                        .frame(maxWidth: SCREEN_WIDTH/1.4, alignment: .leading)
                        .task {
                            imageURL = room.members.first(where: {$0.uuid == message.from})?.uuid ?? "xxx"
                    }
                }
                
                Spacer()
            }.padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message(id: "", type: "text", from: "", body: "Hey everyone! Who's up for a pick-up soccer game tomorrow at the park? Bring your cleats and a positive attitude. Game starts at 3pm. See you there!", timestamp: 0)
        let room = Room(id: "", name: "Admin's Chat", type: "Group", members: [ChatMember](), history: [Message]())
        let peek = UserPeek(firstName: "Jane", lastName: "Doe", username: "janeDoe", imageURL: "profile-images/62D674D2-59D2-4095-952B-4CE6F55F681F", bio: "", sports: ["soccer","tennis"])
        MessageView(room: room, data: peek, message: message)
            .environmentObject(SessionStore())
    }
}
