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
                    // Use a plain Button instead of NavigationLink to avoid the Form/List
                    // row treating the entire section as a navigation target
                    Button(action: { showVenuePicker = true }) {
                        Text("Add")
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.Background.secondary)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if hasSelectedVenue {
                ForEach(manager.selectedVenueDescriptors, id: \.self) { descriptor in
                    HStack {
                        VenueDescriptorView(item: descriptor)
                        Button(action: { manager.removeVenueDescriptor(descriptor) }) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.red)
                                .frame(width: 50, height: 100)
                                .overlay {
                                    Image(systemName: "xmark")
                                        .fontWeight(.bold)
                                        .imageScale(.large)
                                        .foregroundStyle(.white)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Button(action: { showVenuePicker = true }) {
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
                .buttonStyle(.plain)
            }
        }
        .fullScreenCover(isPresented: $showVenuePicker, content: {
            EventVenuePicker(manager: manager)
                .environment(session)
        })
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
