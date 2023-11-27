//
//  FieldsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//

import SwiftUI

struct FieldsView: View {
    
    @Binding var fields: [Field]
    @Binding var status: LOADING_STATE
    
    var body: some View {
        VStack {
            if status == .success {
                if fields.isEmpty {
                    VStack(alignment: .center){
                        Text("😞 Sorry there are no fields in your area.")
                    }.frame(width: SCREEN_WIDTH, height: 200)
                } else {
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(fields.prefix(3), id: \.name){ field in
                                FieldView(field: field)
                            }
                        }
                    }.frame(width: SCREEN_WIDTH, height: 365, alignment: .center)
                }
            } else {
                FieldViewTemplate()
            }
        }
    }
}

struct FieldsView_Previews: PreviewProvider {
    static var previews: some View {
        FieldsView(fields: .constant(FIELDS), status: .constant(.loading))
    }
}
