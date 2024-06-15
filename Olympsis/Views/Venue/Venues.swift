//
//  FieldsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//

import SwiftUI

struct Venues: View {
    
    @Binding var venues: [Venue]
    @Binding var status: LOADING_STATE
    
    @State private var showRequestLocation: Bool = false
    
    @EnvironmentObject private var session: SessionStore
    
    var hasLocation: Bool {
        return session.locationManager.isAuthorized
    }
    
    var body: some View {
        VStack {
            if status == .success {
                if venues.isEmpty {
                    VStack(alignment: .leading){
                        Text("😞 \(String(localized: "Sorry there are no venues in your area", table: "General"))")
                            .padding(.vertical, 5)
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle")
                                .imageScale(.small)
                            Text(String(localized: "Events can be created anywhere, venues are locations vetted by Olympsis", table: "General"))
                                .font(.caption2)
                        }.foregroundStyle(.gray)
                        
                        if !hasLocation {
                            HStack {
                                Spacer()
                                Button(action: { self.showRequestLocation.toggle() }) {
                                    Image(systemName: "location.slash")
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }.padding(.top)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                } else {
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(venues.prefix(3), id: \.name){ field in
                                VenueListItem(venue: field)
                            }
                        }
                    }.frame(width: SCREEN_WIDTH, height: 365, alignment: .center)
                }
            } else {
                VenueListItemTemplate()
            }
        }.fullScreenCover(isPresented: $showRequestLocation, content: {
            LocationRequestView()
        })
    }
}

struct FieldsView_Previews: PreviewProvider {
    static var previews: some View {
        Venues(venues: .constant([]), status: .constant(.success))
            .environmentObject(SessionStore())
    }
}
