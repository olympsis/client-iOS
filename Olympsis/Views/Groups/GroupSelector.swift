//
//  GroupSelector.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import SwiftUI
import Kingfisher

struct GroupSelector: View {
    
    @Binding var showNewGroup: Bool
    
    @State private var selection: UUID?
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    var groups: [GroupSelection] = []
    
    var body: some View {
        VStack {
            List(selection: $selection) {
                Section {
                    ForEach(groups.filter({ $0.type == GROUP_TYPE.Club })) { c in
                        HStack {
                            if let logo = c.club?.logo,
                               let url = generateImageURL(logo) {
                                KFImage(url)
                                    .placeholder({
                                        ImageLoadingView()
                                    })
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
                        }
                    }
                } header: {
                    Text("Clubs")
                }
                if (groups.filter({ $0.type == GROUP_TYPE.Organization }).count != 0) {
                    Section {
                        ForEach(groups.filter({ $0.type == GROUP_TYPE.Organization })) { c in
                            HStack {
                                if let logo = c.organization?.logo,
                                   let url = generateImageURL(logo) {
                                    KFImage(url)
                                        .placeholder({
                                            ImageLoadingView()
                                        })
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
                                Text(c.organization?.name ?? "club_name")
                            }
                        }
                    } header: {
                        Text("Organizations")
                    }
                }
            }.listStyle(.plain)
            Button(action:{
                self.presentationMode.wrappedValue.dismiss()
                self.showNewGroup.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create a new Group")
                    }.foregroundStyle(.white)
                }
            }.frame(height: 50)
                .padding(.all)
        }
        .onChange(of: selection) { _, _ in
            guard let select = groups.first(where: { $0.id == selection }) else {
                self.presentationMode.wrappedValue.dismiss()
                return
            }
            session.selectedGroup = select
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    GroupSelector(showNewGroup: .constant(false), groups: GROUP_SELECTIONS)
}
