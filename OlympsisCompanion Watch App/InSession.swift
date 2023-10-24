//
//  InSession.swift
//  OlympsisCompanion Watch App
//
//  Created by Joel on 10/15/23.
//

import SwiftUI

struct InSession: View {
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack {
            Button(action: {}) {
                ZStack {
                    Circle()
                        .foregroundColor(Color("color-secnd"))
                    Image(systemName: session.selectedSport.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.primary)
                        .padding(.all, 30)
                }.frame(maxWidth: .infinity)
            }.buttonStyle(PlainButtonStyle())
            Text("Start")
                .padding(.vertical)
                .italic()
        }.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text(session.selectedSport.name)
            }
        }
    }
}

#Preview {
    InSession().environmentObject(SessionStore())
}
