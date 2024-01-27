//
//  EventFieldPicker.swift
//  Olympsis
//
//  Created by Joel on 12/13/23.
//

import SwiftUI

/// A simple view to help users pick which fields near them they would like to host an event at
struct EventFieldPickerView: View {
    
    @Binding var selectedField: Field?
    @State var fields: [Field]
    
    @State private var search: String = ""
    @State private var showCustom: Bool = false
    @State private var customField: FieldDescriptor?
    @State private var selectedCustomField = SelectedCustomField(field: nil)
    
    @Environment(\.dismiss) private var dismiss
    
    func sortSelected(item1: Field, item2: Field) -> Bool {
        guard let field = selectedField else {
            return item1.name > item2.name
        }
        if item1.id == field.id {
            return true
        } else if item2.id == field.id {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .trailing) {
                    TextField("Field name", text: $search)
                        .padding(.leading)
                        .modifier(InputField())
                        .padding(.horizontal)
                    Button(action:{ self.showCustom.toggle() }) {
                        Text("Use a Custom Location")
                            .padding(.horizontal)
                    }
                }
                ScrollView {
                    ForEach(search != "" ? fields.filter{$0.name.contains(search)}.sorted(by: { field1, field2 in
                        sortSelected(item1: field1, item2: field2)
                    }) : fields.sorted(by: { field1, field2 in
                        sortSelected(item1: field1, item2: field2)
                    })) { f in
                        HStack {
                            Button(action: { selectedField = f }) {
                                selectedField?.id == f.id ? Image(systemName: "circle.fill") : Image(systemName: "circle")
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
                .sheet(isPresented: $showCustom, onDismiss: {
                    
                    // On dismiss if we have selected a custom field we want to add it to the fields array.
                    // That way we can see the selected custom location.
                    Task { @MainActor in
                        guard let custom = selectedCustomField.field,
                              let location = custom.location,
                              let name = custom.name else {
                            return
                        }
                        let field = Field(id: UUID().uuidString, name: name, owner: Ownership(name: "", type: ""), description: "external", sports: [String](), images: [String](), location: location, city: selectedCustomField.subAdministrativeArea, state: selectedCustomField.administrativeArea, country: selectedCustomField.country)
                        selectedField = field
                        fields.append(field)
                    }
                }, content: {
                    EventFieldCustomPicker(selected: $selectedCustomField)
                })
                .task {
                    guard let field = selectedField else {
                        return
                    }
                    if (fields.first(where: { $0.id == field.id}) == nil) {
                        fields.append(field)
                    }
                }
        }
    }
}

#Preview {
    EventFieldPickerView(selectedField: .constant(FIELDS[0]), fields: FIELDS)
        .environmentObject(SessionStore())
}
