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
                Button(action: { self.showTypePicker.toggle() }){
                    HStack {
                        switch eventType {
                        case .Regular:
                            Image(systemName: "octagon.fill")
                                .foregroundStyle(.white)
                        case .Competitive:
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.white)
                        }
                        Text(eventType.rawValue.prefix(1).capitalized + eventType.rawValue.dropFirst())
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
                
                Button(action: { self.showVisibilityPicker.toggle() }){
                    HStack {
                        switch eventVisibility {
                        case .Public:
                            Image(systemName: "globe.americas.fill")
                                .foregroundStyle(.white)
                        case .Private:
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.white)
                        case .Group:
                            Image(systemName: "person.3.fill")
                                .foregroundStyle(.white)
                        }
                        Text(eventVisibility.rawValue.prefix(1).capitalized + eventVisibility.rawValue.dropFirst())
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                    }.padding(.horizontal)
                        .padding(.vertical, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color("color-prime"))
                        }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical)
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
