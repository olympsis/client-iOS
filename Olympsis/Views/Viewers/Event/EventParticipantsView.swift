//
//  EventParticipantsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventParticipantsView: View {
    @Binding var event: Event
    var body: some View {
        if let part = event.participants {
            if part.count > 0 {
                ScrollView(.horizontal ,showsIndicators: false){
                    HStack {
                        ForEach(part, id:\.id) { p in
                            ParticipantView(participant: p)
                        }
                    } .padding(.leading)
                }
            }
        }
    }
}

struct EventParticipantsView_Previews: PreviewProvider {
    static var previews: some View {
        EventParticipantsView(event: .constant(EVENTS[0]))
    }
}
