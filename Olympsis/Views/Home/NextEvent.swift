//
//  NextEvents.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/29/24.
//

import SwiftUI

struct NextEvent: View {
    
    @Environment(SessionStore.self) private var session
    
    private var event: Event? {
        guard let user = session.user,
              let uuid = user.uuid else {
            return nil
        }
        
        return Array(session.events).mostRecentForUser(uuid: uuid)
    }
    
    var body: some View {
        if let e = event {
            if session.state == .success {
                VStack (alignment: .center){
                    EventListItem(event: e)
                        .padding(.horizontal)
                        .padding(.bottom, -10)
                }
            }
        }
    }
}

#Preview {
    NextEvent()
        .environment(SessionStore())
}
