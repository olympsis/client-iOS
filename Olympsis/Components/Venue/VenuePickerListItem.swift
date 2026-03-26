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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(venue.name)
                    .font(.title2)
                    .lineLimit(1)
                
                if isExternal {
                    Image(systemName: "checkmark.seal")
                        .foregroundColor(Color.Brand.quaternary)
                }
                
                Spacer()
            }
            
            addressRows
                .foregroundStyle(.gray)
        }
    }
    
    // Renders the address rows: street on its own line (if present),
    // then city/state/postal/country with the country bolded.
    @ViewBuilder
    private var addressRows: some View {
        if let fullAddress = venue.fullAddress {
            let lines = fullAddress.components(separatedBy: "\n")
            if lines.count >= 2 {
                // Line 1: street number + street name
                Text(lines[0])
                    .lineLimit(1)
                // Line 2: city, state postal, country — country bolded
                localityText(lines[1])
            } else {
                Text(fullAddress)
                    .lineLimit(1)
            }
        } else {
            // Fallback when no full address is stored on the venue
            (Text("\(venue.city), \(venue.state) ") + Text(venue.country).fontWeight(.bold))
                .lineLimit(1)
        }
    }
    
    // Splits "City, State PostalCode, Country" on the last ", " and bolds the country.
    private func localityText(_ line: String) -> some View {
        let parts = line.components(separatedBy: ", ")
        if parts.count > 1, let country = parts.last {
            let prefix = parts.dropLast().joined(separator: ", ")
            return AnyView(
                (Text("\(prefix), ") + Text(country).fontWeight(.bold))
                    .lineLimit(1)
            )
        }
        return AnyView(Text(line).lineLimit(1))
    }
}

#Preview {
    VenuePickerListItem(venue: VENUES[0])
}
