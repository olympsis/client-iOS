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
    @State private var requiresTeams: Bool = false
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
                
                VStack(alignment: .leading) {
                    Toggle(isOn: $requiresTeams) {
                        Text(String(localized: "advanced-settings-requires-teams-title", defaultValue: "Requires Teams?", table: "Events"))
                            .font(.headline)
                            .bold()
                    }
                    
                    Text(String(localized: "advanced-settings-requires-teams-sub-title", defaultValue: "Does this event require teams to participate?", table: "Events"))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }.padding([.top, .horizontal])
                
                MenuButton(icon: Image(systemName: "figure.run.square.stack.fill"), text: String(localized: "advanced-settings-select-formats", table: "Events")) {
                    router.append(EventFormattingRoutes.formats)
                }.padding(.top)
                
                Spacer()
            }
            .background {
                Color.Background.primary.ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Load data from the manager if we already have some
                if let config = manager.formatConfig, let isCompetition = config.isCompetition {
                    isTournament = isCompetition
                }
                // Reflect whether teams are already configured for this event
                requiresTeams = manager.teamsConfig != nil
            }
            .onDisappear {
                // Make sure we update the manager config on dissmiss of this view
                if manager.formatConfig != nil {
                    manager.formatConfig?.isCompetition = isTournament
                } else {
                    manager.formatConfig = EventFormatConfig(isCompetition: isTournament)
                }
                
                // The "requires teams" toggle is the source of truth for teamsConfig.
                // Enabling it seeds an empty config (preserving any existing one);
                // disabling it clears the config entirely.
                if requiresTeams {
                    manager.teamsConfig = manager.teamsConfig ?? TeamsConfig()
                } else {
                    manager.teamsConfig = nil
                }
            }
            .navigationDestination(for: EventFormattingRoutes.self) { route in
                switch (route) {
                default:
                    NewEventCompetitionFromatSelector()
                        .environment(manager)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }.tint(.primary)
    }
}

#Preview {
    VStack {}.sheet(isPresented: .constant(true)) {
        NewEventFormatting()
            .environment(NewEventManager())
            .presentationDetents([.medium])
    }
}
