//
//  NewGroup.swift
//  Olympsis
//
//  Created by Joel on 11/13/23.
//

import SwiftUI

struct NewGroup: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("What would you like to create?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(destination: NewClub()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
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
                                .font(.callout)
                        }
                    }
                }.frame(height: 250)
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                NavigationLink(destination: NewOrganization()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color("background"))
                        VStack {
                            Image(systemName: "trophy.fill")
                                .imageScale(.large)
                                .padding(.all, 5)
                            Text("Organization")
                                .font(.title3)
                                .bold()
                            Text("An official group that hosts events, and is often a “parent” to multiple smaller clubs within. Provides the ability to broadcast messages and announcements.")
                                .padding(.horizontal)
                                .font(.callout)
                        }
                    }
                }.frame(height: 250)
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                
                Spacer()
            }.padding(.horizontal)
                .navigationTitle("New Club")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewGroup()
}
