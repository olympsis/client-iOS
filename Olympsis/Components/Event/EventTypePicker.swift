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
                    Text("An informal game, for people to come play without any prior registration required. Can be set to Public or Invite Only.")
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
                    Text("A recurring competitive season where teams or individuals play a series of matches over time.")
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
                    Text("A competitive event where individuals or teams compete in a structured format to determine a winner.")
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
                    Text("A structured training session or instructional event led by a coach or instructor.")
                        .font(.callout)
                        .padding(.horizontal)
                }.padding(.vertical)
                    .padding(.horizontal)

                Spacer()

            }
            .padding(.top)
            .navigationTitle("Type")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { dismiss() }) {
                                Text("DONE")
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
                                Text("DONE")
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
