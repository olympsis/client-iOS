//
//  NewEventSportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

struct NewEventSportsPicker: View {
    
    @Binding var selectedSport: SPORTS
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(SPORTS.allCases, id: \.self) { sport in
                    Button(action: { selectedSport = sport }) {
                        SportView(sport: sport, scale: .Medium)
                            .padding(.horizontal, 3)
                            .overlay {
                                if (selectedSport == sport) {
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
    NewEventSportsPicker(selectedSport: .constant(.soccer))
}
