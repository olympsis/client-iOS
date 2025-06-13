//
//  NewEventCompetitionFromatSelector.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/12/25.
//

import SwiftUI

struct NewEventCompetitionFromatSelector: View {
    @State private var selectedFormats: Set<CompetitionFormats> = []
    @Environment(NewEventManager.self) private var manager
    
    private var competitionFormats: [CompetitionFormats] {
        var formats = [CompetitionFormats]()
        for sport in manager.selectedSports {
            formats.append(contentsOf: sport.applicableFormats)
        }
        return formats
    }
    
    private func toggleSelection(_ format: CompetitionFormats) {
        withAnimation(.interpolatingSpring) {
            if selectedFormats.contains(format) {
                selectedFormats.remove(format)
            } else {
                selectedFormats.insert(format)
            }
        }
    }
    
    var body: some View {
        VStack {
            WrappingHStack(alignment: .leading) {
                if !competitionFormats.isEmpty {
                    ForEach(competitionFormats, id: \.self) { format in
                        Button(action: { toggleSelection(format) }) {
                            CompetitionFormatView(format: format, selected: selectedFormats.contains(format))
                        }
                    }
                } else {
                    Text(String(localized: "no-selected-sport", table: "Events"))
                        .padding(.top)
                }
            }
            .padding(.horizontal)
            .onDisappear {
                guard !Array(selectedFormats).isEmpty else { return }
                guard let config = manager.formatConfig else {
                    manager.formatConfig = EventFormatConfig(formats: Array(competitionFormats))
                    return
                }
                config.formats = Array(selectedFormats)
                manager.formatConfig = config
            }
            
            Spacer()
        }
    }
}

#Preview {
    NewEventCompetitionFromatSelector()
        .environment(NewEventManager())
}
