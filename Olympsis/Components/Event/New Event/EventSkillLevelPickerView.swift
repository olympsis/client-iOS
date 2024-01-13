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
                    Text("All players regardless of their skill level is invited to this event.")
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
                    Text("All players at a beginner skill level and up are invited to join this event.")
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
                    Text("All players at an Amateur skill level and up are invited to this event.")
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
                    Text("All players at an Expert skill level and up are inivited to this event.")
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                    .padding(.top)
                
                Spacer()
                
            }.padding(.top)
            .navigationTitle("Skill Level")
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
    EventSkillLevelPickerView(level: .constant(.All))
}
