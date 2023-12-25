//
//  UserDataListView.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import SwiftUI

struct UserDataListView: View {
    
    @State var data: UserData
    @State private var status: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    var imageURL: String {
        guard let imageURL = data.imageURL else {
            return "https://api.olympsis.com"
        }
        return imageURL
    }
    
    var username: String {
        guard let username = data.username else {
            return "olympsis_user"
        }
        return username
    }
    
    var fullName: String {
        guard let firstName = data.firstName,
              let lastName = data.lastName else {
            return "..."
        }
        return firstName + " " + lastName
    }
    
    func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    func inviteUser() async {
        self.status = .loading
        guard let sender = session.user?.uuid,
            let recipient = data.uuid,
              let organizationID = session.selectedGroup?.organization?.id else {
            handleFailure()
            return
        }
        
        let data = Invitation(id: nil, type: GROUP_TYPE.Organization.rawValue, sender: sender, recipient: recipient, subjectID: organizationID, status: "pending", data: nil, createdAt: nil)
        guard let resp = await session.orgObserver.createInvitation(data: data) else {
            handleFailure()
            return
        }
        
        session.invitations.append(resp)
        status = .success
    }
    
    
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: GenerateImageURL(imageURL))){ phase in
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
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                            Color.gray // Acts as a placeholder.
                                .clipShape(Circle())
                                .opacity(0.3)
                                .frame(width: 45, height: 45)
                        }
                    } else {
                        ZStack {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("color-prime"))
                            Color.gray // Acts as a placeholder.
                                .clipShape(Circle())
                                .opacity(0.3)
                                .frame(width: 45, height: 45)
                        }
                    }
            }.frame(width: 45, height: 45)
                .padding(.trailing, 10)
            VStack(alignment: .leading) {
                Text(username)
                    .font(.body)
                    .bold()
                Text(fullName)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Button(action: { Task { await inviteUser() } }) {
                LoadingButton(text: "Invite", width: 100, status: $status)
            }
        }.padding(.horizontal)
    }
}

#Preview {
    UserDataListView(data: USERS_DATA[1])
        .environmentObject(SessionStore())
}
