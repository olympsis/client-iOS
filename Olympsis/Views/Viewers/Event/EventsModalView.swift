//
//  EventsModalView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EventsModalView: View {
    
    @Binding var events: [Event]
    @State var fields: [Field]
    @State private var showMore = false
    @EnvironmentObject var session: SessionStore
    
    // Later on we want to make it so if the field isnt in the cache we go fetch it.
    func getField(fieldId: String) -> Field? {
        return fields.first(where: {$0.id == fieldId })
    }
    
    var todayEvents: [Event] {
        let calendar = Calendar.current
        return events.filter({ calendar.component(.day, from: Date(timeIntervalSince1970: TimeInterval($0.startTime!))) == calendar.component(.day, from: Date())})
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Nearby Events")
                    .font(.system(.headline))
                    .padding()
                Spacer()
                Text("Today")
                    .padding()
                    .foregroundColor(Color("primary-color"))
                Button(action:{ self.showMore.toggle() }){
                    HStack {
                        Text("More")
                            .bold()
                        Image(systemName: "chevron.down")
                    }.padding(.trailing)
                }.foregroundColor(.primary)
            }
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(todayEvents, id: \.title) { event in
                    EventView(event: event, events: $events)
                }
            }.fullScreenCover(isPresented: $showMore) {
                EventsList(fields: fields, events: $events)
            }
        }
    }
}

struct EventsModalView_Previews: PreviewProvider {
    static var previews: some View {
        EventsModalView(events: .constant([Event]()), fields: [Field]())
    }
}
