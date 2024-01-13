//
//  NewEventTopView.swift
//  Olympsis
//
//  Created by Joel on 12/22/23.
//

import SwiftUI

struct NewEventTopView: View {
    
    @Binding var showVisibilityPicker: Bool
    @Binding var showSkillLevelPicker: Bool
    @Binding var eventSkilLevel: EVENT_SKILL_LEVELS
    @Binding var eventVisibility: EVENT_VISIBILITY_TYPES
    
    var body: some View {
        HStack {
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
                        Rectangle()
                            .foregroundStyle(Color("color-prime"))
                    }
            }
            
            Button(action: { self.showSkillLevelPicker.toggle() }){
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.white)
                    Text(eventSkilLevel.rawValue)
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundStyle(.white)
                }.padding(.horizontal)
                    .padding(.vertical, 5)
                    .background {
                        Rectangle()
                            .foregroundStyle(Color("color-prime"))
                    }
            }
            
            Spacer()
        }.padding(.horizontal)
            .padding(.vertical)
            .fullScreenCover(isPresented: $showVisibilityPicker) {
                EventVisibilityPickerView(visibility: $eventVisibility)
            }
            .fullScreenCover(isPresented: $showSkillLevelPicker) {
                EventSkillLevelPickerView(level: $eventSkilLevel)
            }
    }
}

#Preview {
    NewEventTopView(showVisibilityPicker: .constant(false), showSkillLevelPicker: .constant(false), eventSkilLevel: .constant(.All), eventVisibility: .constant(.Public))
}
