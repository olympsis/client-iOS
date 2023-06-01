//
//  EventsList.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventsList: View {
    
    @State var fields: [Field]
    @Binding var events: [Event]
    @State private var selectedDate = Date()
    @State private var state: LOADING_STATE = .pending
    
    @StateObject private var eventObserver = EventObserver()
    @Environment(\.dismiss) private var dismiss
    
    // Later on we want to make it so if the field isnt in the cache we go fetch it.
    func getField(fieldId: String) -> Field? {
        return fields.first(where: {$0.id == fieldId })
    }
    
    var currentEvents: [Event] {
        let calendar = Calendar.current
        return events.filter({ calendar.component(.day, from: Date(timeIntervalSince1970: TimeInterval($0.startTime))) == calendar.component(.day, from: selectedDate)})
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(currentEvents, id: \.title) { event in
                        if let f = getField(fieldId: event.fieldID) {
                            EventView(event: event, field: f, events: $events)
                        } else {
                            EventTemplateView()
                        }
                        
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("primary-color"))
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
        EventsList(fields: FIELDS, events: .constant([Event]()))
    }
}
