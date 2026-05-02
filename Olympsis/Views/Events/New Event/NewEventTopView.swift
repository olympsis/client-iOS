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
                
                Spacer()
            }
            .fullScreenCover(isPresented: $showTypePicker) {
                EventTypePicker(type: $eventType)
            }
            .fullScreenCover(isPresented: $showVisibilityPicker) {
                EventVisibilityPickerView(visibility: $eventVisibility)
            }
        }
    }
}

#Preview {
    NewEventTopView(showTypePicker: .constant(false), showVisibilityPicker: .constant(false), eventType: .constant(.Regular), eventVisibility: .constant(.Public))
}
