//
//  EventVenuePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

struct EventVenuePickerView: View {
    
    let manager: NewEventManager
    @State private var search: String = ""
    @State private var showPicker: Bool = false
    @State private var hideLocation: Bool = false
    
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
                
                Text(String(localized: "pick-a-location-text", table: "Events"))
                
                Spacer()
                Spacer()
                
            }.frame(height: 44)
            
            Button(action: { showPicker.toggle() }) {
                HStack {
                    Image(systemName: "plus")
                    Text(String(localized: "add-a-location-text", table: "Events"))
                }
                .modifier(InputFieldModifier())
                .padding(.horizontal)
            }.padding(.vertical)
            
            // MARK: - Hide Locations
            VStack(alignment: .leading){
                Toggle(isOn: $hideLocation) {
                    Text(String(localized: "event-hide-locations", table: "Events"))
                        .font(.headline)
                        .bold()
                }
                Text(String(localized: "event-show-locations-after-rsvp", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }.padding([.bottom, .horizontal])
            
            List {
                ForEach(manager.selectedVenues, id: \.id) {
                    VenueMediumListItem(item: $0)
                }
                .onDelete(perform: manager.deleteVenues)
            }
            .sheet(isPresented: $showPicker, content: {
                EventVenuePicker(manager: manager)
                    .environment(session)
            })
        }
        .onAppear {
            // Set variable from manager
            guard let config = manager.config else { return }
            hideLocation = config.hideLocation ?? false
        }
        .onDisappear {
            // Handle hide location config
            guard var config = manager.config else {
                manager.config = .init(hideLocation: hideLocation ? true : nil)
                return
            }
            config.hideLocation = hideLocation ? true : nil
            manager.config = config
        }
    }
}

#Preview {
    EventVenuePickerView(manager: NewEventManager())
        .environment(SessionStore())
}
