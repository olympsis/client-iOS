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
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(session.groups.filter({ $0.type == GROUP_TYPE.Club })) { c in
                        HStack {
                            if let logo = c.club?.logo,
                               let url = generateImageURL(logo) {
                                KFImage(url)
                                    .placeholder({
                                        ImageLoadingView()
                                    })
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color("background"))
                                    .opacity(0.3)
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        Image(systemName: "person.2")
                                    }
                            }
                            
                            Text(c.club?.name ?? "club_name")
                                .fontWeight(session.selectedGroup?.id == c.id ? .bold : .regular)
                            
                        }.onTapGesture {
                            selection = c.id
                        }
                    }
                } header: {
                    Text("Clubs")
                }
                
                if (session.groups.filter({ $0.type == GROUP_TYPE.Organization }).count != 0) {
                    Section {
                        ForEach(session.groups.filter({ $0.type == GROUP_TYPE.Organization })) { o in
                            HStack {
                                if let logo = o.organization?.logo,
                                   let url = generateImageURL(logo) {
                                    KFImage(url)
                                        .placeholder({
                                            ImageLoadingView()
                                        })
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color("background"))
                                        .opacity(0.3)
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Image(systemName: "building")
                                        }
                                }
                                
                                Text(o.organization?.name ?? "club_name")
                                    .fontWeight(session.selectedGroup?.id == o.id ? .bold : .regular)
                                
                            }.onTapGesture {
                                selection = o.id
                            }
                        }
                    } header: {
                        Text("Organizations")
                    }
                }
            }.listStyle(.plain)
            
            Button(action:{ self.showNewGroup.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create a new Group")
                    }.foregroundStyle(.white)
                }
            }
            .frame(height: 50)
            .padding(.all)
        }
        .fullScreenCover(isPresented: $showNewGroup, content: {
            NewGroup()
        })
        .onChange(of: selection) { _, _ in
            Task {
                await MainActor.run {
                    guard let selection = session.groups.first(where: { $0.id == selection }) else {
                        dismiss()
                        return
                    }
                    session.selectedGroup = selection
                }
            }
        }
    }
}

#Preview {
    let session = SessionStore()
    session.groups = GROUP_SELECTIONS
    return GroupSelector()
        .environmentObject(session)
}
