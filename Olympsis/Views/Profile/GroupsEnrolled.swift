//
//  GroupsEnrolled.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI

struct GroupsEnrolled: View {
    
    private var clubs: [Club] {
        var arr = [Club]()
        let groups = session.groups.filter { $0.type == .Club }
        groups.forEach { group in
            guard let club = group.club else { return }
            arr.append(club)
        }
        return arr
    }
    
    private var organizations: [Organization] {
        var arr = [Organization]()
        let groups = session.groups.filter { $0.type == .Organization }
        groups.forEach { group in
            guard let organization = group.organization else { return }
            arr.append(organization)
        }
        return arr
    }
    
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("Clubs")
                    .font(.title)
                    .bold()
                
                if (clubs.isEmpty) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("No Clubs Enrolled")
                                .padding(.top)
                            
                            Text("Go join one!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                } else {
                    ForEach(clubs, id: \.id) { club in
                        ClubListItem(club: club, showToast: .constant(false), showActions: false)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(minHeight: 200)
            
            if !organizations.isEmpty {
                VStack(alignment: .leading) {
                    Text("Organizations")
                        .font(.title)
                        .bold()
                    
                    ForEach(organizations, id: \.id) { organization in
                        OrgListItem(organization: organization, showToast: .constant(false), showActions: false)
                    }
                }
                .padding()
                .frame(minHeight: 200)
            }
            
        }.frame(maxWidth: SCREEN_WIDTH)
    }
}

#Preview {
    GroupsEnrolled()
        .environment(SessionStore())
}
