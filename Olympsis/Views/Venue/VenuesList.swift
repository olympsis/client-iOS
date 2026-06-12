//
//  FieldsList.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct VenuesList: View {
    
    @State var venues:[Venue]
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    @State private var showRequestLocation: Bool = false
    
    var hasLocation: Bool {
        return LocationManager.shared.isAuthorized
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if (venues.count > 0) {
                    // Neighborhood-grouped index with quick-jump chips. The
                    // grouping/caching lives in the shared component so the
                    // Home "view all" sheet and the Events explorer drawer
                    // render venues identically.
                    VenueNeighborhoodIndex(venues: venues)
                } else {
                    if hasLocation {
                        VStack {
                            Text(String(localized: "no-venues-text", table: "General"))
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle")
                                    .imageScale(.small)
                                Text(String(localized: "olympsis-locations-text", table: "General"))
                                    .font(.caption2)
                            }.foregroundStyle(.gray)
                        }.padding(.all)
                    } else {
                        VStack {
                            Text(String(localized: "no-venues-text", table: "General"))
                                .padding(.bottom, 5)
 
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle")
                                    .imageScale(.small)
                                Text(String(localized: "olympsis-locations-text", table: "General"))
                                    .font(.caption2)
                            }.foregroundStyle(.gray)
                        }
                        .padding(.all)
                        .fullScreenCover(isPresented: $showRequestLocation, onDismiss: {
                            Task {
                                await session.updateNotifications()
                            }
                        }) {
                            LocationRequestView()
                        }
                    }
                }
            }
            .scrollToTopButton()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ dismiss() }){
                        Image(systemName: "chevron.left")
                    }
                }
                if !hasLocation {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { self.showRequestLocation.toggle() }) {
                            Image(systemName: "location.slash")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "nearby-venues", table: "General"))
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showRequestLocation, content: {
                LocationRequestView()
            })
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        dismiss()
                    }
                }
        )
    }
}

#Preview {
    VenuesList(venues: [Venue]())
        .environment(SessionStore())
}
