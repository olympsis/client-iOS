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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "new-event-sports-title", table: "Events").uppercased())
                .font(.caption)
                .bold()
            
            HStack {
                ScrollView(.horizontal) {
                    ForEach(selectedSports, id: \.name) { sport in
                        Text(sport.name.prefix(1).uppercased() + sport.name.dropFirst())
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 26)
                                    .foregroundStyle(Color.Background.tertiary)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 26)
                                            .stroke(Color.border)
                                    }
                            }
                    }
                }
                Button(action: { showSports.toggle() }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.primary)
                }.background {
                    RoundedRectangle(cornerRadius: 26)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.Background.tertiary)
                }
                .padding(.trailing, 10)
            }
            .padding(10)
            .frame(minHeight: 60)
            .background {
                RoundedRectangle(cornerRadius: 26)
                    .foregroundStyle(Color.Background.secondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.border)
                    }
            }
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
    NewEventSportsPicker(sports: SPORTS_TEMP, selectedSports: .constant([SPORTS_TEMP[0]]))
}
