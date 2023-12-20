//
//  EventFieldPicker.swift
//  Olympsis
//
//  Created by Joel on 12/13/23.
//

import SwiftUI

/// A simple view to help users pick which fields near them they would like to host an event at
struct EventFieldPickerView: View {
    
    @Binding var selectedField: Field
    @State var fields: [Field]
    @State private var search: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextField("Field name", text: $search)
                    .padding(.leading)
                    .modifier(InputField())
                    .padding(.horizontal)
                ScrollView {
                    ForEach(search != "" ? fields.filter{ $0.name.contains(search) } : fields) { f in
                        HStack {
                            Button(action: { selectedField = f }) {
                                selectedField.id == f.id ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                            }.padding(.all)
                            VStack(alignment: .leading) {
                                Text(f.name)
                                Text("\(f.city), \(f.state)")
                                    .font(.callout)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                        }.padding(.horizontal)
                    }
                }
            }.navigationTitle("Fields")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { dismiss() }) {
                            Text("DONE")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background {
                                    Rectangle()
                                }
                        }
                    }
                }
        }
    }
}

#Preview {
    EventFieldPickerView(selectedField: .constant(FIELDS[0]), fields: FIELDS)
}
