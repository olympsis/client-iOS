//
//  TransitLabel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/15/26.
//

import SwiftUI

struct TransitLabel: View {
    
    var transit: TransitLine
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(hex: transit.color))
                    .frame(width: 35, height: 35)
                
                Text(transit.name)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
            }
            
            HStack(alignment: .top) {
                Text(transit.type.prefix(1).uppercased())
                +
                Text(transit.type.dropFirst(1))
                Text(transit.system)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    let transit = TransitLine(id: UUID().uuidString, type: "subway", name: "Q", system: "MTA", color: "#FCCC0A", iconURL: "", locality: "", administrativeArea: "", countryCode: "")
    TransitLabel(transit: transit)
}
