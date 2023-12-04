//
//  NewGroup.swift
//  Olympsis
//
//  Created by Joel on 11/13/23.
//

import SwiftUI

struct NewGroup: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("What type of group would you like to create?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(destination: NewClub()) {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color("background"))
                        VStack {
                            Image(systemName: "person.3.fill")
                                .imageScale(.large)
                                .padding(.all, 5)
                            Text("Club")
                                .font(.title3)
                                .bold()
                            Text("A club is a social circle uniting individuals who share a common interest in a sport or fitness goal, providing a platform to create group chats and organize events related to those shared interests.")
                                .padding(.horizontal)
                                .font(.caption)
                        }
                    }
                }.frame(height: 250)
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                NavigationLink(destination: NewOrganization()) {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color("background"))
                        VStack {
                            Image(systemName: "globe.americas.fill")
                                .imageScale(.large)
                                .padding(.all, 5)
                            Text("Organization")
                                .font(.title3)
                                .bold()
                            Text("An organization is typically limited in terms of its feature set, offering a standardized structure for various clubs or groups within it. It often provides the ability to broadcast messages or information to its affiliated clubs.")
                                .padding(.horizontal)
                                .font(.caption)
                        }
                    }
                }.frame(height: 250)
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                
                Spacer()
            }.padding(.horizontal)
                .navigationTitle("New Group")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
        }
    }
}

#Preview {
    NewGroup()
        .environmentObject(SessionStore())
}
