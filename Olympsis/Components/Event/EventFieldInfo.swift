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
        guard field.city != "" else {
            return ""
        }
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
                if field.description == "external" {
                    UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[1]),\(field.location.coordinates[0])")! as URL)
                } else {
                    self.showSheet.toggle()
                }
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
