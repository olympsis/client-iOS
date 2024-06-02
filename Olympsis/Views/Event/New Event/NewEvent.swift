//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import os
import SwiftUI

struct NewEvent: View {
    
    @StateObject var manager: NewEventManager
    @State private var selection: Int = 0
    @State private var showPickUp: Bool = false
    @State private var showTournament: Bool = false
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selection) {
                    VStack(alignment: .center) {
                        Text("What type of event would you like to create?")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color("background"))
                            VStack {
                                Text("Pick Up")
                                    .font(.title3)
                                    .bold()
                                Text("An informal game, for people to come play without any prior registration required. Can be set to Public or Invite Only.")
                                    .padding(.horizontal)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                            }
                        }.frame(height: 250)
                            .padding(.horizontal)
                            .foregroundStyle(.primary)
                            .onTapGesture {
                                selection = 1
                            }
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color("background"))
                            VStack {
                                Text("Tournament")
                                    .font(.title3)
                                    .bold()
                                Text("A competitive event where individuals or teams compete in a structured format to determine a winner.  May or may not require prior registration. ")
                                    .padding(.horizontal)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                            }
                        }.frame(height: 250)
                            .padding(.horizontal)
                            .foregroundStyle(.primary)
                            .disabled(true)
                            .onTapGesture {
                                selection = 2
                            }
                        
                        Spacer()
                        
                    }.padding(.horizontal)
                        .navigationTitle("New Event")
                        .navigationBarTitleDisplayMode(.inline)
                        .tag(0)
                    
                    NewPickUpEvent()
                        .environmentObject(manager)
                        .tag(1)
                    
                    NewTournamentEvent()
                        .environmentObject(manager)
                        .tag(2)
                    
                }.tabViewStyle(.automatic)
            }.navigationTitle("New Event")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

#Preview {
    NewEvent(manager: NewEventManager())
        .environmentObject(SessionStore())
}
