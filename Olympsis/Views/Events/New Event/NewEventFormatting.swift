//
//  NewEventFormatting.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/1/25.
//

import SwiftUI

struct NewEventFormatting: View {
    
    enum EventFormattingRoutes {
        case formats
    }
    
    @State private var router = NavigationPath()
    @State private var isTournament: Bool = false
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        NavigationStack(path: $router) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Toggle(isOn: $isTournament) {
                        Text(String(localized: "advanced-settings-tournament-title", table: "Events"))
                            .font(.headline)
                            .bold()
                    }
                    
                    Text(String(localized: "advanced-settings-tournament-sub-title", table: "Events"))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }.padding([.top, .horizontal])
                
                
                MenuButton(icon: Image(systemName: "figure.run.square.stack.fill"), text: String(localized: "advanced-settings-select-formats", table: "Events")) {
                    router.append(EventFormattingRoutes.formats)
                }.padding(.top)
                
                Spacer()
            }
            .onAppear {
                // Load data from the manager if we already ahve some
                guard let config = manager.formatConfig,
                      let isCompetition = config.isCompetition else { return }
                isTournament = isCompetition
            }
            .onDisappear {
                // Make sure we update the manager config on dissmiss of this view
                manager.formatConfig = EventFormatConfig(isCompetition: isTournament)
            }
            .navigationDestination(for: EventFormattingRoutes.self) { route in
                switch (route) {
                default:
                    NewEventCompetitionFromatSelector()
                        .environment(manager)
                }
            }
        }.tint(.primary)
    }
}

#Preview {
    NewEventFormatting()
        .environment(NewEventManager())
}
