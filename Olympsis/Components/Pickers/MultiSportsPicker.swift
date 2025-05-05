//
//  ProfileSportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/24.
//

import SwiftUI

struct MultiSportsPicker: View {
    
    var sports: [Sport]
    @Binding var selectedSports: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    func toggleSport(_ sport: Sport) {
        let name = sport.name.components(separatedBy: " ")[1]
        guard !selectedSports.contains(name) else {
            selectedSports.remove(name)
            return
        }
        selectedSports.insert(name)
    }
    
    func isSelected(_ sport: Sport) -> Bool {
        let name = sport.name.components(separatedBy: " ")[1]
        return selectedSports.contains(name)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            Spacer(minLength: 20)
            WrappingHStack(alignment: .bottomLeading) {
                ForEach(sports, id: \.name) { sport in
                    Button(action: { toggleSport(sport) }) {
                        SportView(sport: sport)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected(sport) ? Color.primary : Color.black.opacity(0.2), lineWidth: 1)
                            )
                    }.buttonStyle(PlainButtonStyle())
                }
            }.padding(.horizontal)
        }
        .padding(.top)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    MultiSportsPicker(sports: SPORTS_TEMP, selectedSports: .constant(["soccer", "tennis"]))
}
