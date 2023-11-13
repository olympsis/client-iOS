//
//  EventsModalView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

/// A view that shows the most recent and nearby events
struct EventsModalView: View {
    
    @State private var showMore = false
    @EnvironmentObject var session: SessionStore
    
    var todayEvents: [Event] {
        let calendar = Calendar.current
        return session.events.filter({ calendar.component(.day, from: Date(timeIntervalSince1970: TimeInterval($0.startTime!))) == calendar.component(.day, from: Date())})
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
                    .foregroundColor(Color("color-prime"))
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
                    EventView(event: event)
                }
            }.fullScreenCover(isPresented: $showMore) {
                EventsList(events: session.events)
            }
        }
    }
}

struct EventsModalView_Previews: PreviewProvider {
    static var previews: some View {
        EventsModalView().environmentObject(SessionStore())
    }
}
