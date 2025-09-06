//
//  VenuePickerListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/6/25.
//

import SwiftUI

struct VenuePickerListItem: View {
    
    var venue: Venue
    var isExternal: Bool = false
    
    private var name: String {
        return venue.name
    }
    
    private var address: Text {
        guard let address = venue.fullAddress else {
            return Text("\(venue.city), \(venue.state) ") + Text(venue.country).fontWeight(.bold)
        }
        
        let components = address.trimmingPrefix(" ").components(separatedBy: "-")
        guard let first = components.first,
              let last = components.last else {
            return Text(address)
        }
        return Text("\(first)") + Text(last).fontWeight(.bold)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(venue.name)
                    .font(.title2)
                    .lineLimit(1)
                
                if (isExternal) {
                    Image(systemName: "checkmark.seal")
                        .foregroundColor(Color.Brand.quaternary)
                }
                
                Spacer()
            }
            
            address
                .lineLimit(1)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    VenuePickerListItem(venue: VENUES[0])
}
