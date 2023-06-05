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
    @EnvironmentObject var session:SessionStore
    
    var uuid: String {
        guard let user = session.user,
              let uuid = user.uuid else {
            return ""
        }
        return uuid
    }
    
    var isPoster: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let poster = event.poster else {
            return false
        }
        return poster == uuid
    }
    
    var body: some View {
        ZStack {
            VStack {
                EventDetailRSVPButton(event: $event)
                if isPoster {
                    EventDetailActionButton(event: $event, showMenu: $showMenu)
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
        EventDetailActions(event: .constant(EVENTS[0]), showMenu: .constant(false))
    }
}
