//
//  GroupSelector.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import SwiftUI
import Kingfisher

struct GroupSelector: View {
    
    @State private var selection: UUID?
    @State private var showNewGroup = false
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    private var groups: [GroupSelection] {
        return session.groupsManager.groups
    }
    
    private var clubs: [GroupSelection] {
        return groups.filter({ $0.type == GROUP_TYPE.Club })
    }
    
    private var organizations: [GroupSelection] {
        return groups.filter({ $0.type == GROUP_TYPE.Organization })
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(clubs) { g in
                        GroupSelectionListItem(selectedGroup: g, selectionID: $selection)
                            .onTapGesture {
                                selection = g.id
                            }
                    }
                } header: {
                    Text("Clubs")
                }
                
                if (organizations.count != 0) {
                    Section {
                        ForEach(organizations) { g in
                            GroupSelectionListItem(selectedGroup: g, selectionID: $selection)
                                .onTapGesture {
                                    selection = g.id
                                }
                        }
                    } header: {
                        Text("Organizations")
                    }
                }
            }
            .listStyle(.plain)
            
            Button(action:{ self.showNewGroup.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.colorPrime)
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create a new Group")
                    }
                    .foregroundStyle(Color.white)
                }
            }
            .frame(height: 50)
            .padding(.all)
        }
        .fullScreenCover(isPresented: $showNewGroup, content: {
            NewClub()
        })
        .onChange(of: selection) { _, _ in
            Task { @MainActor in
                guard let selection = groups.first(where: { $0.id == selection }),
                      let selectedGroup = session.groupsManager.selected,
                      selectedGroup.id != selection.id else {
                    return
                }
//                session.selectedGroup = selection
                session.groupsManager.select(selection)
                dismiss()
            }
        }
        .task {
            guard let selectedGroup = session.groupsManager.selected else {
                return
            }
            self.selection = selectedGroup.id
        }
    }
}

#Preview {
    let session = SessionStore()
    session.groupsManager.groups = GROUP_SELECTIONS
    return GroupSelector()
        .environment(session)
}
