//
//  SportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import SwiftUI

struct SportsPicker: View {
    
    @Binding var selectedSports: [SPORTS]
    @State var multiSelection = false
    
    private func handleTap(_ sport: SPORTS) {
        if (!multiSelection) { selectedSports.removeAll() }
        guard let idx = selectedSports.firstIndex(where: { $0 == sport }) else {
            selectedSports.append(sport)
            return
        }
        selectedSports.remove(at: idx)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(SPORTS.allCases, id: \.self) { sport in
                    Button(action: { handleTap(sport) }) {
                        SportView(sport: sport, scale: .Medium)
                            .padding(.horizontal, 3)
                            .overlay {
                                if (selectedSports.contains(where: { $0 == sport})) {
                                    Circle().stroke(Color.Brand.secondary, lineWidth: 3)
                                }
                            }
                    }.buttonStyle(PlainButtonStyle())
                }.frame(height: 103)
            }
        }.scrollIndicators(.hidden)
    }
}

#Preview {
    SportsPicker(selectedSports: .constant([]))
}
