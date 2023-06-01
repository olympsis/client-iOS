//
//  EventDetailActions.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailActions: View {
    
    @Binding var event: Event
    @Binding var showMenu: Bool
    @State var user: UserData
    @State var eventObserver: EventObserver
    
    var body: some View {
        ZStack {
            VStack {
                EventDetailRSVPButton(event: $event, user: user, eventObserver: eventObserver)
                if event.poster == user.uuid {
                    EventDetailActionButton(event: $event, showMenu: $showMenu, eventObserver: eventObserver)
                }
            }.padding(.all, 8)
            .background {
                Rectangle()
                    .cornerRadius(10)
                    .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
            }
        }.padding(.bottom, 50)
            .padding(.trailing)
    }
}

struct EventDetailActions_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailActions(event: .constant(EVENTS[0]), showMenu: .constant(false), user: USERS_DATA[0], eventObserver: EventObserver())
    }
}
