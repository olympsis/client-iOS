//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import os
import SwiftUI

struct NewEvent: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("What type of event would you like to create?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(destination: NewPickUpEvent()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color("background"))
                        VStack {
                            Image(systemName: "figure.2")
                                .imageScale(.large)
                                .padding(.all, 5)
                            Text("Pick Up")
                                .font(.title3)
                                .bold()
                            Text("An informal game, for people to come play without any prior registration required. Can be set to Public or Invite Only.")
                                .padding(.horizontal)
                                .font(.callout)
                        }
                    }
                }.frame(height: 250)
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                NavigationLink(destination: NewTournamentEvent()) {
                    ZStack (alignment: .topTrailing){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color("background"))
                            VStack {
                                Image(systemName: "trophy.fill")
                                    .imageScale(.large)
                                    .padding(.all, 5)
                                Text("Tournament")
                                    .font(.title3)
                                    .bold()
                                Text("A competitive event where individuals or teams compete in a structured format to determine a winner.  May or may not require prior registration. ")
                                    .padding(.horizontal)
                                    .font(.callout)
                            }
                        }
                        
                        Image(systemName: "circle.slash")
                            .padding()
                            .imageScale(.large)
                            .foregroundStyle(.gray)
                    }
                }.frame(height: 250)
                    .padding(.horizontal)
                    .foregroundStyle(.primary)
                    .disabled(true)
                
                Spacer()
            }.padding(.horizontal)
                .navigationTitle("New Event")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewEvent()
        .environmentObject(SessionStore())
}
