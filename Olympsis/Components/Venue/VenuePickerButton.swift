//
//  VenuePickerButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/7/25.
//

import SwiftUI

struct VenuePickerButton: View {
    
    @Binding var validationStatus: NEW_EVENT_ERROR?
    
    private var hasSelectedVenue: Bool {
        return !manager.selectedVenues.isEmpty || !manager.selectedVenueDescriptors.isEmpty
    }
    
    @Environment(SessionStore.self) private var session
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(String(localized: "new-event-location-title", table: "Events"))
                        .font(.headline)
                        .bold()
                    Text(String(localized: "new-event-location-sub-title", table: "Events"))
                        .font(.subheadline)
                        .foregroundColor(validationStatus == .noSelectedField ? .red : .gray)
                }
                
                Spacer()
                
                
                if hasSelectedVenue {
                    NavigationLink(destination: EventVenuePicker(manager: manager).environment(session)) {
                        Text("Edit Venue(s)")
                            .italic()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2.5)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.Background.secondary)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                            }
                    }
                }
            }
            
            if hasSelectedVenue {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center) {
                    ForEach(manager.selectedVenueDescriptors, id: \.self) { descriptor in
                        VenueDescriptorView(item: descriptor)
                            .overlay(alignment: .topTrailing) {
                                Button(action: { manager.removeVenueDescriptor(descriptor) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(.red)
                                }
                            }
                    }
                }
            } else {
                NavigationLink(destination: EventVenuePicker(manager: manager).environment(session)) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.Background.secondary)
                        .frame(height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                        }
                        .overlay {
                            Text(String(localized: "pick-a-location-text", table: "Events"))
                        }
                }
            }
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
