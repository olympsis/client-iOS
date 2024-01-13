//
//  RSVP.swift
//  Olympsis
//
//  Created by Joel on 7/22/23.
//

import SwiftUI

struct RSVP: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ScrollView {
            VStack {
                Text("RSVP!!")
                    .bold()
                    .font(.custom("ITCAvantGardeStd-Bold", size: 25, relativeTo: .largeTitle))
                Text("It is polite to RSVP to your club’s events ")
                    .font(.subheadline)
                
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("You don’t have to be going to an event to RSVP. We provide three options: Yes, No and Maybe")
                }.padding(.top)
                    .padding(.top)
                    .padding(.horizontal)
                
                Image("rsvp")
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    Image(systemName: "clock")
                    Text("Please only say yes if you are certain that you will attend. Try to be on time some fields are only reserved for a certain time.")
                }.padding(.top)
                    .padding(.top)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "person.3")
                    Text("If you would like to get more information about an event besides the ones given in the event view, please request to join the hosting club and ask the members.")
                }.padding(.top)
                    .padding(.top)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "mountain.2")
                    Text("Some events have preferred skill levels, please keep that in mind when responding to events.")
                }.padding(.top)
                    .padding(.top)
                    .padding(.horizontal)
                
                Image("levels")
                    .resizable()
                    .scaledToFit()
                
                Button(action: { self.presentationMode.wrappedValue.dismiss() }){
                    SimpleButtonLabel(text: "Ok")
                }.padding(.top)
            }
        }
    }
}

struct RSVP_Previews: PreviewProvider {
    static var previews: some View {
        RSVP()
    }
}

