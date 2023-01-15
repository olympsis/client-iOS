//
//  FieldsList.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct FieldsList: View {
    @State var fields:[Field]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(fields, id: \.name){ field in
                    FieldView(field: field)
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("primary-color"))
                    }
                }
            }
            .navigationTitle("Nearby Fields")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FieldsList_Previews: PreviewProvider {
    static var previews: some View {
        FieldsList(fields: [Field]())
    }
}
