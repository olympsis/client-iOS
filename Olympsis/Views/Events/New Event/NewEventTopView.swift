//
//  NewEventTopView.swift
//  Olympsis
//
//  Created by Joel on 12/22/23.
//

import SwiftUI

struct NewEventTopView: View {

    @Binding var showTypePicker: Bool
    @Binding var showVisibilityPicker: Bool

    @Binding var eventType: EVENT_TYPES
    @Binding var eventVisibility: EVENT_VISIBILITY_TYPES
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TYPE")
                        .font(.caption)
                    
                    Button(action: {self.showTypePicker.toggle() }) {
                        HStack {
                            // Icon comes straight from the picker's EVENT_TYPES.image() so the
                            // button and the picker always show the same symbol for a given type.
                            eventType.image()
                                .foregroundStyle(.white)
                            Text(eventType.displayName())
                                .foregroundStyle(.white)
                            Image(systemName: "chevron.down")
                                .imageScale(.small)
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color("color-prime"))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("VISIBILITY")
                        .font(.caption)
                    
                    Button(action: { self.showVisibilityPicker.toggle() }){
                        HStack {
                            switch eventVisibility {
                            case .Public:
                                Image(systemName: "globe.americas.fill")
                                    .foregroundStyle(.white)
                                Text(String(localized: "visibility-public", table: "Events"))
                                    .foregroundStyle(.white)
                                Image(systemName: "chevron.down")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                            case .Private:
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.white)
                                Text(String(localized: "visibility-private", table: "Events"))
                                    .foregroundStyle(.white)
                                Image(systemName: "chevron.down")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                            case .Group:
                                Image(systemName: "person.3.fill")
                                    .foregroundStyle(.white)
                                Text(String(localized: "visibility-group", table: "Events"))
                                    .foregroundStyle(.white)
                                Image(systemName: "chevron.down")
                                    .imageScale(.small)
                                    .foregroundStyle(.white)
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color("color-prime"))
                        }
                    }
                }

                Spacer()
            }
            .sheet(isPresented: $showTypePicker) {
                EventTypePicker(type: $eventType)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showVisibilityPicker) {
                EventVisibilityPickerView(visibility: $eventVisibility)
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    NewEventTopView(showTypePicker: .constant(false), showVisibilityPicker: .constant(false), eventType: .constant(.Regular), eventVisibility: .constant(.Public))
}
