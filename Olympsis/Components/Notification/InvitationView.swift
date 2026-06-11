//
//  InvitationView.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import SwiftUI

struct InvitationView: View {
    
    @State var invitation: Invitation
    @State private var acceptState: LOADING_STATE = .pending
    @State private var denyState: LOADING_STATE = .pending
    @Environment(SessionStore.self) private var session
    
    func handleAcceptSuccess() {
        acceptState = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            acceptState = .pending
        }
    }
    
    func handleAcceptFailure() {
        acceptState = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            acceptState = .pending
        }
    }
    
    func handleDenySuccess() {
        denyState = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            denyState = .pending
        }
    }
    
    func handleDenyFailure() {
        denyState = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            denyState = .pending
        }
    }
    
    func acceptInvite() async {
        let dto = InvitationDTO(id: nil, type: "", sender: "", recipient: "", subjectID: "", status: "accepted", createdAt: nil)
        let resp = await session.orgObserver.updateInvitation(data: dto)
        guard resp else {
            handleAcceptFailure()
            return
        }
        guard let org = await session.orgObserver.getOrganization(id: invitation.subjectID) else {
            handleAcceptSuccess()
            return
        }
        let group = GroupSelection(type: GROUP_TYPE.Organization, club: nil, organization: org, posts: nil)
        session.groupsManager.add(group)
        invitation.id = ""
        session.invitations = [Invitation]()
        handleAcceptSuccess()
    }
    
    func denyInvite() async {
        let dto = InvitationDTO(id: nil, type: "", sender: "", recipient: "", subjectID: "", status: "denied", createdAt: nil)
        let resp = await session.orgObserver.updateInvitation(data: dto)
        guard resp else {
            handleDenyFailure()
            return
        }
        handleDenySuccess()
    }
    
    var body: some View {
        if invitation.type == "organization" {
            HStack(alignment: .top) {
                if let imageURL = invitation.data?.organization?.logo {
                    AsyncImage(url: URL(string: GenerateImageURL(imageURL))){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .clipped()
                            } else if phase.error != nil {
                                ZStack {
                                    Rectangle()
                                        .stroke(Color.Foreground.default, lineWidth: 1.0)
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                }
                            } else {
                                ZStack {
                                    Rectangle()
                                        .opacity(0.1)
                                        .frame(width: 50, height: 50)
                                        .accentColor(Color.Foreground.default)
                                    ProgressView()
                                }
                            }
                    }.frame(width: 50, height: 50, alignment: .center)
                }
                
                VStack(alignment: .leading) {
                    if let name = invitation.data?.organization?.name {
                        Text("Invitation")
                            .bold()
                        Text("You've been invited to join ")
                        + Text("\(name)").bold()
                    }
                    HStack {
                        Button(action: { Task { await acceptInvite() }}) {
                            LoadingButton(text: "Accept", height: 40, status: $acceptState)
                        }
                        Spacer()
                        Button(action: { Task { await denyInvite()} }) {
                            LoadingButton(text: "Deny", height: 40, color: .red, status: $denyState)
                        }
                    }.padding(.vertical)
                }.padding(.leading, 5)
            }.padding(.horizontal)
        }
    }
}

#Preview {
    InvitationView(invitation: INVITATIONS[0])
        .environment(SessionStore())
}
