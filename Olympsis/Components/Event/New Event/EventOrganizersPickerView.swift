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
    @State var organizers: [GroupSelection]
    @State var clubs: [Club]
    @State var organizations: [Organization]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                // Sorting by selected. So when you select something it goes to the top of the list
                ForEach(organizers.sorted(by: { a, b in
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
                            Circle()
                                .frame(height: 60)
                            if let club = clubs.first(where: { $0.id == organizer.club?.id }) {
                                if let name = club.name {
                                    Text(name)
                                }
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
                            Circle()
                                .frame(height: 60)
                            if let org = organizations.first(where: { $0.id == organizer.organization?.id }) {
                                if let name = org.name {
                                    Text(name)
                                }
                            }
                            Spacer()
                        }.padding(.horizontal)
                    }
                }
                Spacer()
            }.padding(.top)
            .navigationTitle("Organizers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("DONE")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .background {
                                Rectangle()
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    EventOrganizersPickerView(selectedOrganizers: .constant([GroupSelection]()), organizers: GROUPS, clubs: CLUBS, organizations: ORGANIZATIONS)
}
