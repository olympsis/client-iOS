//
//  MessageView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import SwiftUI

struct MessageView: View {
    
    @State var room: Room
    @State var data: UserData?
    @State var message: Message
    
    @EnvironmentObject var session: SessionStore
    
    var isMe: Bool {
        guard let user = session.user,
              let uuid = user.uuid else {
            return false
        }
        return message.sender == uuid
    }
    
    var username : String {
        guard let user = data,
              let username = user.username else {
            return "@OlympsisUser"
        }
        return "@\(username)"
    }
    
    var imageURL : String {
        guard let user = data,
              let image = user.imageURL else {
            return ""
        }
        return GenerateImageURL(image)
    }
    
    var body: some View {
        if isMe {
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
                AsyncImage(url: URL(string: imageURL)){ phase in
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
                
                
                VStack(alignment: .leading) {
                    Text(username)
                        .font(.caption)
                        .frame(height: 3)
                        .padding(.leading, 5)
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
                }
                
                Spacer()
            }.padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let message = Message(id: 0, type: "text", sender: "", body: "Hey everyone! Who's up for a pick-up soccer game tomorrow at the park? Bring your cleats and a positive attitude. Game starts at 3pm. See you there!", timestamp: 0)
        let room = Room(id: "", name: "Admin's Chat", type: "Group", members: [ChatMember](), history: [Message]())
        MessageView(room: room, data: USERS_DATA[0], message: message)
            .environmentObject(SessionStore())
    }
}
