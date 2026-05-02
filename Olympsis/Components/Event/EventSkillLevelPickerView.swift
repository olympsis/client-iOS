//
//  EventSkillLevelPicker.swift
//  Olympsis
//
//  Created by Joel on 12/13/23.
//

import SwiftUI

/// A simple view to help users pick out what skill level they would like the participants of their events to have
struct EventSkillLevelPickerView: View {
    
    @Binding var level: EVENT_SKILL_LEVELS
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { level = .All }) {
                            level.rawValue == EVENT_SKILL_LEVELS.All.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_SKILL_LEVELS.All.rawValue)
                            .bold()
                    }
                    Text(String(localized: "skill-level-all-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { level = .Beginner }) {
                            level.rawValue == EVENT_SKILL_LEVELS.Beginner.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_SKILL_LEVELS.Beginner.rawValue)
                            .bold()
                    }
                    Text(String(localized: "skill-level-beginner-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { level = .Amateur }) {
                            level.rawValue == EVENT_SKILL_LEVELS.Amateur.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_SKILL_LEVELS.Amateur.rawValue)
                            .bold()
                    }
                    Text(String(localized: "skill-level-amateur-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { level = .Expert }) {
                            level.rawValue == EVENT_SKILL_LEVELS.Expert.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_SKILL_LEVELS.Expert.rawValue)
                            .bold()
                    }
                    Text(String(localized: "skill-level-expert-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                    .padding(.top)
                
                Spacer()
                
            }.padding(.top)
            .navigationTitle(String(localized: "skill-level-title", table: "Events"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { dismiss() }) {
                            Text(String(localized: "done", table: "General"))
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background {
                                    Rectangle()
                                        .foregroundStyle(Color.Brand.primary)
                                }
                        }
                    }
                }
        }
    }
}

#Preview {
    EventSkillLevelPickerView(level: .constant(.All))
}
