//
//  NewEventSportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

struct NewEventSportsPicker: View {
    
    var sports: [Sport]
    @Binding var selectedSports: [Sport]
    @State private var showSports: Bool = false
    
    private var sportName: String {
        var text = String(localized: "new-event-sport-action-text", table: "Events")
        guard let firstSport = selectedSports.first else { return text }
        text = firstSport.name
        guard let firstIndex = text.firstIndex(where: { $0.isLetter }) else { return text }
        text.replaceSubrange(firstIndex...firstIndex, with: text[firstIndex].uppercased())
        return text
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "new-event-sports-title", table: "Events"))
                .font(.headline)
                .bold()
            Text(String(localized: "new-event-sport-sub-title", table: "Events"))
                .foregroundColor(.gray)
                .font(.subheadline)
            
            Button(action: { showSports.toggle() }) {
                Text(sportName)
            }
            .modifier(InputFieldModifier())
            .scrollIndicators(.hidden)
                
        }
        .sheet(isPresented: $showSports) {
            ScrollView(.vertical) {
                Spacer(minLength: 20)
                WrappingHStack(alignment: .bottomLeading) {
                    ForEach(sports, id: \.name) { sport in
                        Button(action: {
                            selectedSports = [sport]
                            showSports.toggle()
                        }) {
                            SportView(sport: sport)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.horizontal)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NewEventSportsPicker(sports: SPORTS_TEMP, selectedSports: .constant([]))
}
