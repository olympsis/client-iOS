//
//  EventFieldInfo.swift
//  Olympsis
//
//  Created by Joel on 12/11/23.
//

import SwiftUI

struct EventFieldInfo: View {
    
    @State var field: Field
    @State private var showSheet: Bool = false
    
    private var fieldLocality: String {
        return field.city + ", " + field.state
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(field.name)
                .font(.title3)
                .bold()
                .foregroundStyle(Color("foreground"))
                
            Text(fieldLocality)
                .foregroundStyle(Color("foreground"))
        }.padding(.leading)
            .onTapGesture {
                self.showSheet.toggle()
            }
        .sheet(isPresented: $showSheet, content: {
            FieldViewExt(field: field)
        })
    }
}

#Preview {
    EventFieldInfo(field: FIELDS[0])
        .environmentObject(SessionStore())
}
