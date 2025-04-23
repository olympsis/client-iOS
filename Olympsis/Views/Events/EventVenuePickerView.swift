//
//  EventVenuePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

struct EventVenuePickerView: View {
    
    @State var manager: NewEventManager
    @State private var search: String = ""
    @State private var showPicker: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .padding(.horizontal)
                }.clipShape(Rectangle())
                
                Spacer()
                Spacer()
                
                Text("Pick a Location")
                
                Spacer()
                Spacer()
                
            }.frame(height: 44)
            ScrollView {
                Button(action: { showPicker.toggle() }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add a Location")
                    }
                    .modifier(InputFieldModifier())
                    .padding(.horizontal)
                }.padding(.vertical)
                
                ForEach(manager.selectedVenues, id: \.id) {
                    VenueMediumListItem(item: $0)
                }
                .onDelete(perform: manager.deleteVenues)
                .padding(.horizontal)
            }.sheet(isPresented: $showPicker, content: {
                EventVenuePicker(manager: manager)
                    .environment(session)
            })
        }
    }
}

#Preview {
    EventVenuePickerView(manager: NewEventManager())
        .environment(SessionStore())
}
