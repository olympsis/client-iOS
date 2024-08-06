//
//  EventVisibilityPicker.swift
//  Olympsis
//
//  Created by Joel on 12/13/23.
//

import SwiftUI

/// A simple view to help users pick and understand the event visibility settings
struct EventVisibilityPickerView: View {
    
    @Binding var visibility: EVENT_VISIBILITY_TYPES
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { visibility = .Public }) {
                            visibility.rawValue == EVENT_VISIBILITY_TYPES.Public.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_VISIBILITY_TYPES.Public.rawValue.prefix(1).capitalized + EVENT_VISIBILITY_TYPES.Public.rawValue.dropFirst())
                            .bold()
                    }
                    Text("Anyone on olympsis can see this event and interact with it.")
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { visibility = .Private }) {
                            visibility.rawValue == EVENT_VISIBILITY_TYPES.Private.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_VISIBILITY_TYPES.Private.rawValue.prefix(1).capitalized + EVENT_VISIBILITY_TYPES.Private.rawValue.dropFirst())
                            .bold()
                    }
                    Text("Only you, the participants and the others you invite will see this event.")
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { visibility = .Group }) {
                            visibility.rawValue == EVENT_VISIBILITY_TYPES.Group.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(EVENT_VISIBILITY_TYPES.Group.rawValue.prefix(1).capitalized + EVENT_VISIBILITY_TYPES.Group.rawValue.dropFirst())
                            .bold()
                    }
                    Text("Anyone that is a part of the groups associated with this event will be abe to see and interact with with it.")
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                
                Spacer()
                
            }.padding(.top)
            .navigationTitle("Visibility")
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
    EventVisibilityPickerView(visibility: .constant(.Public))
}
