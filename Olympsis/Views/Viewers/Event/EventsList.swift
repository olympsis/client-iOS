//
//  EventsList.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

/// A view that shows a list of events
struct EventsList: View {
    
    @State var events = [Event]()
    @State private var selectedDate = Date()
    @State private var state: LOADING_STATE = .pending
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.dismiss) private var dismiss
    
    var currentEvents: [Event] {
        let calendar = Calendar.current
        return events.filter({ calendar.component(.day, from: Date(timeIntervalSince1970: TimeInterval($0.startTime!))) == calendar.component(.day, from: selectedDate)})
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(currentEvents, id: \.title) { event in
                        EventView(event: event)
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("color-prime"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date).datePickerStyle(.compact)
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EventsList_Previews: PreviewProvider {
    static var previews: some View {
        EventsList()
    }
}
