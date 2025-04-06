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
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(session.groups.filter({ $0.type == GROUP_TYPE.Club })) { g in
                        GroupSelectionListItem(selectedGroup: g, selectionID: $selection)
                            .onTapGesture {
                                selection = g.id
                            }
                    }
                } header: {
                    Text("Clubs")
                }
                
                if (session.groups.filter({ $0.type == GROUP_TYPE.Organization }).count != 0) {
                    Section {
                        ForEach(session.groups.filter({ $0.type == GROUP_TYPE.Organization })) { g in
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
            NewGroup()
        })
        .onChange(of: selection) { _, _ in
            Task { @MainActor in
                guard let selection = session.groups.first(where: { $0.id == selection }),
                      let selectedGroup = session.selectedGroup,
                      selectedGroup.id != selection.id else {
                    return
                }
                session.selectedGroup = selection
                dismiss()
            }
        }
        .task {
            guard let selectedGroup = session.selectedGroup else {
                return
            }
            self.selection = selectedGroup.id
        }
    }
}

#Preview {
    let session = SessionStore()
    session.groups = GROUP_SELECTIONS
    return GroupSelector()
        .environment(session)
}
