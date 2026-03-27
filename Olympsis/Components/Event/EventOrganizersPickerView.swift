//
//  EventOrganizersPicker.swift
//  Olympsis
//
//  Created by Joel on 12/13/23.
//

import SwiftUI

/// A simple view that is used to help users pick out the organizers for their event.
/// Organizers can be clubs and or organizations.
/// You must be a part of these clubs/organizations in order to add them as an organizer (subject to change)
struct EventOrganizersPickerView: View {
    
    @Binding var selectedOrganizers: [GroupSelection]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private var groups: [GroupSelection] {
        guard let user = session.user,
              let userID = user.userID else {
            return []
        }
        return session.groupsManager.groups.filter {
            guard let member = $0.club?.members.first(where: { $0.user?.userID == userID }),
                  member.role != MEMBER_ROLES.Member.rawValue else {
                guard let member = $0.organization?.members.first(where: { $0.user?.userID == userID }),
                      member.role != MEMBER_ROLES.Member.rawValue else {
                    return false
                }
                return true;
            }
            return true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Spacer()
                Text("Organizers")
                    .fontWeight(.bold)
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("DONE")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background {
                            Rectangle()
                                .foregroundStyle(Color.Brand.primary)
                        }
                }
                .padding(.trailing)
            }
            ScrollView {
                // Sorting by selected. So when you select something it goes to the top of the list
                ForEach(groups.sorted(by: { a, b in
                    if ((selectedOrganizers.contains(where: { $0.id == a.id })) && !(selectedOrganizers.contains(where: { $0.id == b.id }))) {
                        return true
                    } else if (!(selectedOrganizers.contains(where: { $0.id == a.id })) && (selectedOrganizers.contains(where: { $0.id == b.id }))){
                        return false
                    } else {
                        return a.type.rawValue < b.type.rawValue
                    }
                })) { organizer in
                    // MARK: - Club View
                    if organizer.type == GROUP_TYPE.Club {
                        HStack {
                            Button(action: {
                                if (selectedOrganizers.contains(where: { $0.id == organizer.id })) {
                                    selectedOrganizers.removeAll(where: { $0.id == organizer.id })
                                } else {
                                    selectedOrganizers.append(organizer)
                                }
                            }) {
                                selectedOrganizers.contains(where: { $0.id == organizer.id }) ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                            }
                            
                            ZStack {
                                Circle()
                                    .frame(height: 60)
                                    .foregroundStyle(Color.Background.secondary)
                                Image(systemName: "person.3.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(Color.foreground)
                            }
                            
                            if let club = session.clubs.first(where: { $0.id == organizer.club?.id }) {
                                Text(club.name)
                            }
                            Spacer()
                        }.padding(.horizontal)
                    } else {
                        // MARK: - Organization View
                        HStack {
                            Button(action: {
                                if (selectedOrganizers.contains(where: { $0.id == organizer.id })) {
                                    selectedOrganizers.removeAll(where: { $0.id == organizer.id })
                                } else {
                                    selectedOrganizers.append(organizer)
                                }
                            }) {
                                selectedOrganizers.contains(where: { $0.id == organizer.id }) ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                            }
                            
                            ZStack {
                                Circle()
                                    .frame(height: 60)
                                    .foregroundStyle(Color.Background.secondary)
                                Image(systemName: "building.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(Color.foreground)
                            }
                            
                            if let org = session.orgs.first(where: { $0.id == organizer.organization?.id }) {
                                Text(org.name)
                            }
                            Spacer()
                        }.padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    EventOrganizersPickerView(selectedOrganizers: .constant([GroupSelection]()))
        .environment(SessionStore())
}
