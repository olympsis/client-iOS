//
//  NewEventFormatting.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/1/25.
//

import SwiftUI

struct NewEventFormatting: View {
    
    @State private var isTournament: Bool = false
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Toggle(isOn: $isTournament) {
                    Text("Is a Tournament?")
                        .font(.headline)
                        .bold()
                }
                
                Text("Toggle competition mode—casual or tournament?")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }.padding([.top, .horizontal])
            
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
    }
}

#Preview {
    NewEventFormatting()
        .environment(NewEventManager())
}
