//
//  EventTypePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/5/25.
//


import SwiftUI

/// A simple view to help users pick and understand the event visibility settings
struct EventTypePicker: View {
    
    @Binding var type: EVENT_TYPES
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { type = .Regular }) {
                            type == EVENT_TYPES.Regular ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_TYPES.Regular.rawValue.prefix(1).capitalized + EVENT_TYPES.Regular.rawValue.dropFirst())
                            .bold()
                    }
                    Text("An informal game, for people to come play without any prior registration required. Can be set to Public or Invite Only.")
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { type = .Competitive }) {
                            type == EVENT_TYPES.Competitive ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_TYPES.Competitive.rawValue.prefix(1).capitalized + EVENT_TYPES.Competitive.rawValue.dropFirst())
                            .bold()
                    }
                    Text("A competitive game where individuals or teams compete in a structured format to determine a winner.  May or may not require prior registration.")
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)
                
                Spacer()
                
            }
            .padding(.top)
            .background(Color.Background.primary)
            .navigationTitle("Type")
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
    EventTypePicker(type: .constant(.Regular))
}
