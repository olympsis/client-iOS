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
        return session.locationManager.isAuthorized
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if (venues.count > 0) {
                    LazyVStack {
                        ForEach(venues, id: \.name){ field in
                            VenueListItem(venue: field)
                        }
                    }
                } else {
                    if hasLocation {
                        VStack {
                            Text(String(localized: "No venues near you", table: "General"))
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle")
                                    .imageScale(.small)
                                Text(String(localized: "Events can be created anywhere, venues are locations vetted by Olympsis", table: "General"))
                                    .font(.caption2)
                            }.foregroundStyle(.gray)
                        }.padding(.all)
                    } else {
                        VStack {
                            Text(String(localized: "No venues near you", table: "General"))
                                .padding(.bottom, 5)
 
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle")
                                    .imageScale(.small)
                                Text(String(localized: "Events can be created anywhere, venues are locations vetted by Olympsis", table: "General"))
                                    .font(.caption2)
                            }.foregroundStyle(.gray)
                        }
                        .padding(.all)
                        .fullScreenCover(isPresented: $showRequestLocation, content: {
                            LocationRequestView()
                        })
                    }
                }
            }
            .background(Color.Background.primary)
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
            .navigationTitle(String(localized: "Nearby Venues", table: "General"))
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showRequestLocation, content: {
                EmptyView()
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

struct FieldsList_Previews: PreviewProvider {
    static var previews: some View {
        VenuesList(venues: [Venue]())
            .environment(SessionStore())
    }
}
