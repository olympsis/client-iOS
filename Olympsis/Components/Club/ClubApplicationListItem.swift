//
//  ClubApplicationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import SwiftUI

struct ClubApplicationListItem: View {
    
    @State var club: Club
    @State var application: ClubApplication
    @Binding var applications: [ClubApplication]
    
    @State private var acceptState: LOADING_STATE = .pending
    @State private var denyState: LOADING_STATE = .pending
    
    @Environment(SessionStore.self) private var session

    
    var fullName: String {
        guard let data = application.applicant,
              let firstName = data.firstName,
              let lastName = data.lastName else {
            return "Olympsis User"
        }
        return firstName + " " + lastName;
    }
    
    var username: String {
        guard let data = application.applicant,
              let username = data.username else {
            return "olympsis-user"
        }
        return "\(username)";
    }
    
    var userBio: String {
        guard let data = application.applicant,
              let bio = data.bio else {
                  return "..."
              }
        return bio;
    }
    
    var userImageURL: URL? {
        guard let data = application.applicant,
              let imageURL = data.imageURL else {
            return nil
        }
        return URL(string: GenerateImageURL(imageURL))
    }
    
    var dateTimeInString: String {
        return application.createdAt.formatted(.dateTime.day().month().year());
    }
    
    func accept() {
        Task { @MainActor in
            acceptState = .loading
            let req = ApplicationUpdateRequest(status: "accepted")
            let res = await session.clubService.updateApplication(id: club.id, appID: application.id, req: req)
            if res {
                acceptState = .success
                withAnimation(.easeOut){
                    self.applications.removeAll(where: {$0.id == application.id})
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.acceptState = .pending
                }
            }
        }
    }
    
    func deny() {
        Task { @MainActor in
            denyState = .loading
            let req = ApplicationUpdateRequest(status: "denied")
            let res = await session.clubService.updateApplication(id: club.id, appID: application.id, req: req)
            if res {
                withAnimation(.easeOut){
                    self.applications.removeAll(where: {$0.id == application.id})
                    
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.denyState = .pending
                }
            }
        }
    }
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                UserBadgeView(size: .large, imageURL: userImageURL, color: Color.Background.tertiary)
                    .padding(.vertical)
                    .padding(.leading)
                    .padding(.trailing, 10)
                
                VStack (alignment: .leading, spacing: 5){
                    HStack(alignment: .top) {
                        Text(fullName)
                            .font(.headline)
                        
                        Text(username)
                            .font(.body)
                            .italic()
                            .foregroundColor(.gray)
                    }
                    
                    Text(calculateTimeAgo(from: application.createdAt))
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            
            ExpandableTextView(text: userBio)
                .padding([.horizontal, .bottom])
            
            HStack {
                Button(action:{ deny() }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.Background.tertiary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                            }
                        
                        switch denyState {
                        case .pending:
                            Text(String(localized: "deny", table: "General"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .foregroundColor(.primary)
                        case .loading, .success:
                            ProgressView()
                        case .failure:
                            Image(systemName: "xmark")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(.trailing)
                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                
                Button(action:{ accept() }){
                    LoadingButton(text: String(localized: "accept", table: "General"), status: $acceptState)
                }
                .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)
                .padding(.leading)
                
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(Color(Color.Background.secondary))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        }
    }
}

#Preview {
    ClubApplicationListItem(club: CLUBS[0], application: CLUB_APPLICATIONS[0], applications: .constant([ClubApplication]()))
        .environment(SessionStore())
        .padding(.horizontal, 10)
}
