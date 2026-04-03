//
//  EventTypePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/5/25.
//


import SwiftUI

/// A simple view to help users pick and understand the event type settings
struct EventTypePicker: View {

    @Binding var type: EVENT_TYPES
    @Environment(\.dismiss) private var dismiss

    /// Converts an uppercase raw value like "REGULAR" to title case "Regular"
    private func displayName(_ eventType: EVENT_TYPES) -> String {
        eventType.rawValue.capitalized
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { type = .Regular }) {
                            type == .Regular ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(displayName(.Regular))
                            .bold()
                    }
                    Text(String(localized: "event-type-regular-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.horizontal)

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { type = .League }) {
                            type == .League ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(displayName(.League))
                            .bold()
                    }
                    Text(String(localized: "event-type-league-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { type = .Tournament }) {
                            type == .Tournament ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(displayName(.Tournament))
                            .bold()
                    }
                    Text(String(localized: "event-type-tournament-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)

                VStack(alignment: .leading) {
                    HStack {
                        Button(action: { type = .Class }) {
                            type == .Class ? Image(systemName: "circle.fill") : Image(systemName: "circle")
                        }
                        Text(displayName(.Class))
                            .bold()
                    }
                    Text(String(localized: "event-type-class-desc", table: "Events"))
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)

                Spacer()

            }
            .padding(.top)
            .navigationTitle(String(localized: "event-type-title", table: "Events"))
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
    EventTypePicker(type: .constant(.Regular))
}
