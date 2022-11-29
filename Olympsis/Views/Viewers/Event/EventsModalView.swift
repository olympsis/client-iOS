//
//  EventsModalView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EventsModalView: View {
    @State var events: [Event]
    @State var fields: [Field]
    @State var isLoading = true
    @EnvironmentObject var session: SessionStore
    
    // Later on we want to make it so if the field isnt in the cache we go fetch it.
    func getField(fieldId: String) -> Field? {
        return fields.first(where: {$0.id == fieldId })
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Nearby Events")
                    .font(.system(.headline))
                    .padding()
                Spacer()
                Text("Today")
                    .bold()
                    .padding()
            }
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(events, id: \.title) { event in
                    if let f = getField(fieldId: event.fieldId) {
                        EventView(event: event, field: f, events: $events)
                    } else {
                        EventTemplateView()
                    }
                    
                }
            }
        }
    }
}

struct EventsModalView_Previews: PreviewProvider {
    static var previews: some View {
        EventsModalView(events: [Event](), fields: [Field]())
    }
}
