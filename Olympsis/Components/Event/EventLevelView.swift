//
//  EventLevelView.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import SwiftUI

/// View that shows the minimum skill level a player ought to have before joining a specific event
struct EventLevelView: View {
    @State var level: Int
    var body: some View {
        VStack {
            if level == 1 {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text(String(localized: "level-beginner", table: "Events"))
                }
            } else if level == 2 {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text(String(localized: "level-amateur", table: "Events"))
                }
            } else if level == 3 {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text(String(localized: "level-expert", table: "Events"))
                }
            } else {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text(String(localized: "level-any", table: "Events"))
                }
            }
        }.padding(.trailing)
            .padding(.all, 7)
    }
}

#Preview {
    EventLevelView(level: 0)
}
