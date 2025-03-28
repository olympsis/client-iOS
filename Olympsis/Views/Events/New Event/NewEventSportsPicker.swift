//
//  NewEventSportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

struct NewEventSportsPicker: View {
    
    var sports: [Sport]
    @Binding var selectedSport: [Sport]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(sports, id: \.name) { sport in
                    Button(action: { selectedSport.append(sport) }) {
                        SportView(sport: sport, scale: .Medium)
                            .padding(.horizontal, 3)
                            .overlay {
                                if (selectedSport.contains(where: { $0.name == sport.name })) {
                                    Circle().stroke(Color.Brand.secondary, lineWidth: 2)
                                }
                            }
                    }.buttonStyle(PlainButtonStyle())
                }.frame(height: 103)
            }
        }.scrollIndicators(.hidden)
            
    }
}

#Preview {
    NewEventSportsPicker(sports: [], selectedSport: .constant([]))
}
