//
//  ManageEvents.swift
//  Olympsis
//
//  Created by Joel on 7/22/23.
//

import SwiftUI

struct ManageEvents: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ScrollView {
            VStack {
                Text("Game Time!!")
                    .bold()
                    .font(.custom("ITCAvantGardeStd-Bold", size: 25, relativeTo: .largeTitle))
                Text("When it’s time or whenever everyone shows up. Let’s start the event and end after they’re done")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Events have a start time and an actual start time; meaning you can either start the event on time or when everyone shows up")
                }.padding(.top)
                    .padding(.top)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "clock")
                    Text("You can stop the event when the group finishes playing. This helps Olympsis use this data to predict how long your club plays during these events.")
                }.padding(.top)
                    .padding(.top)
                    .padding(.horizontal)
                
                Image("EventMenu")
                    .resizable()
                    .scaledToFit()
            
                Button(action: { self.presentationMode.wrappedValue.dismiss() }){
                    SimpleButtonLabel(text: "Ok")
                }.padding(.top)
            }
        }
    }
}

#Preview {
    ManageEvents()
}
