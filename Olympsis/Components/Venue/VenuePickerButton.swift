//
//  VenuePickerButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/7/25.
//

import SwiftUI

struct VenuePickerButton: View {
    
    @Binding var validationStatus: NEW_EVENT_ERROR?
    
    // Controls programmatic navigation to the venue picker
    @State private var showVenuePicker: Bool = false
    
    @Environment(SessionStore.self) private var session
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        VStack(alignment: .leading) {
            // Section title, styled to match the sport / date / organizer sections.
            Text(String(localized: "new-event-location-title", table: "Events").uppercased())
                .font(.caption)
                .bold()
                .foregroundStyle(validationStatus == .noSelectedField ? Color.red : Color.primary)
            
            // MARK: - Selected locations
            // Each selected venue renders as a map card with a red "x" to remove it.
            ForEach(manager.selectedVenueDescriptors, id: \.self) { descriptor in
                VenueDescriptorView(item: descriptor)
                    .overlay(alignment: .topTrailing) {
                        Button(action: { manager.removeVenueDescriptor(descriptor) }) {
                            Image(systemName: "xmark")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background {
                                    Circle()
                                        .foregroundStyle(.red)
                                }
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                    }
            }
            
            // MARK: - Add a location
            // Always available so users can add one or more locations to the event.
            Button(action: { showVenuePicker = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text(String(localized: "add-a-location-text", table: "Events"))
                }
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 26)
                        .foregroundStyle(Color.Background.secondary)
                        .overlay {
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color.border)
                        }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        // The location picker is presented as a sheet with a drag indicator.
        .sheet(isPresented: $showVenuePicker) {
            EventVenuePicker(manager: manager)
                .environment(session)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        VenuePickerButton(validationStatus: .constant(nil))
            .environment(SessionStore())
            .environment(NewEventManager())
            .padding(.horizontal)
    }
}

#Preview ("Selected") {
    let manager = NewEventManager()
    let _ = manager.selectedVenueDescriptors.append(VENUE_DESCRIPTORS[0])
    let _ = manager.selectedVenueDescriptors.append(VENUE_DESCRIPTORS[1])
    
    return NavigationStack {
        VenuePickerButton(validationStatus: .constant(nil))
            .environment(SessionStore())
            .environment(manager)
            .padding(.horizontal)
    }
}
