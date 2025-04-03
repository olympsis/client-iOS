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
        }.onDisappear {
            guard isTournament else { return }
            manager.formatConfig = EventFormatConfig(isCompetition: isTournament)
        }
    }
}

#Preview {
    NewEventFormatting()
        .environment(NewEventManager())
}
