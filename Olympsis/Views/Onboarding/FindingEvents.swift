//
//  SwiftUIView.swift
//  Olympsis
//
//  Created by Joel on 7/22/23.
//

import SwiftUI

struct FindingEvents: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ScrollView {
            VStack {
                Text("Finding Events")
                    .bold()
                    .font(.custom("ITCAvantGardeStd-Bold", size: 25, relativeTo: .largeTitle))
                Text("Where's pickup at?")
                    .font(.subheadline)
                
                Text("Events are shown in the map view in a small popup, there the events are filtered day by day. So if you want to see tomorrow’s list of events for a field you will have to move the calendar date.")
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.top)
                
                Image("EventsModal")
                    .resizable()
                    .scaledToFit()
                
                Text("You can see events happening in a certain field by opening up the field detail view. Those events are not filtered by their start date and are not separated by day.")
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.top)
                
                Image("FieldEvents")
                    .resizable()
                    .scaledToFit()
                
                Button(action: { self.presentationMode.wrappedValue.dismiss() }){
                    SimpleButtonLabel(text: "Ok")
                }.padding(.top)
            }
        }
    }
}

struct FindingEvents_Previews: PreviewProvider {
    static var previews: some View {
        FindingEvents()
    }
}
