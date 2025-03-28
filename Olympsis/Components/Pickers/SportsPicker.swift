//
//  SportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import SwiftUI

struct SportsPicker: View {
    
    var sports: [Sport]
    @Binding var selectedSports: [Sport]
    @State var multiSelection = false

    private func handleTap(_ sport: Sport) {
        if (!multiSelection) { selectedSports.removeAll() }
        guard let idx = selectedSports.firstIndex(where: { $0.name == sport.name }) else {
            selectedSports.append(sport)
            return
        }
        selectedSports.remove(at: idx)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(sports, id: \.name) { sport in
                    Button(action: { handleTap(sport) }) {
                        SportView(sport: sport, scale: .Medium)
                            .padding(.horizontal, 3)
                            .overlay {
                                if (selectedSports.contains(where: { $0.name == sport.name })) {
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
    SportsPicker(sports: [], selectedSports: .constant([]))
}
