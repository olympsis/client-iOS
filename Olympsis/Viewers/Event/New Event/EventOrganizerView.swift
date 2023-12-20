//
//  NewEventOrganizersView.swift
//  Olympsis
//
//  Created by Joel on 12/14/23.
//

import SwiftUI

struct EventOrganizerView: View {
    
    @Binding var organizers: [GroupSelection]
    
    var body: some View {
        HStack {
            if organizers.count == 1 {
                if let o = organizers.first {
                    if o.type == GROUP_TYPE.Club.rawValue {
                        if let club = o.club,
                           let name = club.name {
                            Text(name)
                        }
                    }
                }
            } else {
                if let o = organizers.first {
                    if o.type == GROUP_TYPE.Club.rawValue {
                        if let club = o.club,
                           let name = club.name {
                            Text(name + " ...")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    EventOrganizerView(organizers: .constant(GROUPS))
}
