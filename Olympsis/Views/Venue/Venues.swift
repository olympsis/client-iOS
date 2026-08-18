//
//  Venues.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//

import SwiftUI

struct Venues: View {
    
    var venues: [Venue]
    var status: LOADING_STATE
    
    @State private var showNewEvent: Bool = false
    @State private var showRequestLocation: Bool = false
    
    @Environment(SessionStore.self) private var session
    
    var hasLocation: Bool {
        return LocationManager.shared.isAuthorized
    }
    
    var body: some View {
        VStack {
            if status == .success {
                if venues.isEmpty {
                    VStack(alignment: .leading){
                        Text("😞 \(String(localized: "no-venues-text", table: "General"))")
                            .padding(.vertical, 5)
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle")
                                .imageScale(.small)
                            Text(String(localized: "olympsis-locations-text", table: "General"))
                                .font(.caption2)
                        }
                        .foregroundStyle(.gray)
                        
                        if !hasLocation {
                            HStack {
                                Spacer()
                                Button(action: { self.showRequestLocation.toggle() }) {
                                    VStack(alignment: .center) {
                                        Image(systemName: "location.slash")
                                            .foregroundStyle(.gray)
                                        Text("Click to share location")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                }
                                Spacer()
                            }.padding(.top)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: { showNewEvent.toggle() }) {
                                SimpleButtonLabel(text: "Create an Event")
                            }
                            Spacer()
                        }
                        .padding(.top)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                } else {
                    // Two stacked rows that scroll horizontally as full-width
                    // "pages". LazyHGrid fills top-to-bottom then moves to the
                    // next column, so each screen-width column holds two venues.
                    ScrollView(.horizontal, showsIndicators: false){
                        LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(venues.prefix(6), id: \.name){ field in
                                VenueListItem(venue: field)
                                    .frame(width: SCREEN_WIDTH - 20)
                            }
                        }
                        // Marks the grid as the snapping unit for viewAligned below
                        .scrollTargetLayout()
                    }
                    // Snap so a column always lands aligned instead of stopping mid-scroll,
                    // and inset the content 10pt each side to center the narrower cards
                    .scrollTargetBehavior(.viewAligned)
                    .contentMargins(.horizontal, 10, for: .scrollContent)
                    .frame(height: 260)
                }
            } else {
                VenueListItemTemplate()
            }
        }
        .fullScreenCover(isPresented: $showRequestLocation, onDismiss: {
            Task {
                await session.updateNotifications()
            }
        }){
            LocationRequestView()
        }
        .fullScreenCover(isPresented: $showNewEvent) {
            NewEvent(manager: NewEventManager(venues: session.venues))
        }
    }
}

struct FieldsView_Previews: PreviewProvider {
    static var previews: some View {
        Venues(venues: [], status: .success)
            .environment(SessionStore())
    }
}
