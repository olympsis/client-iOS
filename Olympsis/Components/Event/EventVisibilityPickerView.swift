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
                        Text(String(localized: "visibility-public", table: "Events"))
                            .bold()
                    }
                    Text(String(localized: "visibility-public-details", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { visibility = .Private }) {
                            visibility.rawValue == EVENT_VISIBILITY_TYPES.Private.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(String(localized: "visibility-private", table: "Events"))
                    }
                    Text(String(localized: "visibility-private-details", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)
                
//                VStack(alignment: .leading) {
//                    HStack {
//                        Button(action: { visibility = .Group }) {
//                            visibility.rawValue == EVENT_VISIBILITY_TYPES.Group.rawValue ? Image(systemName: "circle.fill") : Image(systemName: "circle")
//                        }
//                        Text(String(localized: "visibility-group", table: "Events"))
//                            .bold()
//                    }
//                    Text(String(localized: "visibility-group-details", table: "Events"))
//                        .font(.callout)
//                        .padding(.horizontal)
//                }.padding(.horizontal)
                
                Spacer()
                
            }.padding(.top)
            .navigationTitle(String(localized: "visibility-title", table: "Events"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { dismiss() }) {
                                Text(String(localized: "done", table: "General"))
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                            }
                            .glassEffect(.regular.tint(Color.Brand.primary).interactive())
                        }.sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { dismiss() }) {
                                Text(String(localized: "done", table: "General"))
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.Brand.primary)
                                    }
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
