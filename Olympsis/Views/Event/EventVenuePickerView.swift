//
//  EventVenuePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

struct EventVenuePickerView: View {
    
    @State private var search: String = ""
    @State private var showPicker: Bool = false
    
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var manager: NewEventManager
    
    var body: some View {
        VStack {
            Button(action: { showPicker.toggle() }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add a Location")
                }
                .modifier(InputField())
                .padding(.horizontal)
            }.padding(.vertical)
            
            List {
                ForEach(manager.selectedVenues, id: \.name) {
                    VenueMediumListItem(item: $0)
                }.onDelete(perform: manager.deleteVenues)
            }
        }.sheet(isPresented: $showPicker, content: {
            EventVenuePicker()
                .environmentObject(manager)
                .environmentObject(session)
        })
        .navigationTitle("Pick a location")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    EventVenuePickerView()
        .environmentObject(SessionStore())
        .environmentObject(NewEventManager())
}
