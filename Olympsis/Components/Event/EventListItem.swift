//
//  EventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
import SwiftUI

/// A view that shows an event's data at a glance. A list item.
struct EventListItem: View {
    
    @State var event: Event
    @State private var venue = Venue(
        id: UUID().uuidString,
        name: "Placeholder",
        owner: Ownership(name: "Placeholder", type: "placeholder"),
        description: "Placeholder text about this great venue",
        sports: [""],
        images: ["", "", ""],
        location: GeoJSON(type: "", coordinates: [Double]()),
        city: "Placeholder",
        state: "PH",
        country: "PlaceHolder"
    )
    
    @State private var status: LOADING_STATE = .loading
    @State private var venueState: LOADING_STATE = .pending
    
    @State private var showDetails = false
    @EnvironmentObject private var session:SessionStore
    
    var log: Logger = Logger(subsystem: "com.olympsis.client", category: "event_list_item")
    
    private var title: String {
        guard let title = event.title else {
            return "Event"
        }
        return title
    }
    
    private var imageURL: String {
        guard let img = event.imageURL else {
            return ""
        }
        return img
    }
    
    /// We want to dynamically fetch the venue information to reduce the amount of data we're holding in memory
    ///
    /// We try to fetch the venue locally in memory if we have it stored and if it's an Olympsis vetted location.
    /// If we do not have the venue in memory we will try to fetch it remotely.
    /// If that fails then we will have to display an error.
    ///
    /// If the venue is not Olympsis vetted we will simply just open maps at the provided coordinates
    func fetchVenue() async {
        venueState = .loading
        guard var venue = event.venue else {
            log.error("Failed to verify external venue")
            return
        }
        if (venue.isInternal()) {
            guard let resp = await fetchVenueLocal() else {
                guard let resp = await fetchVenueRemote() else {
                    venueState = .failure
                    return
                }
                self.venue = resp
                venueState = .success
                return
            }
            self.venue = resp
            venueState = .success
        } else {
            guard let name = venue.name,
                  let location = venue.location else {
                log.error("Failed to verify external venue")
                return
            }
            venue.name = name
            venue.location = location
            venueState = .success
        }
        return
    }
    
    /// Fetch the venue from the data we have in memory
    /// - Returns: a `Venue` optional object in case we failt to find venue
    func fetchVenueLocal() async -> Venue? {
        guard let venue = event.venue,
              let venue = session.venues.first(where: { $0.id == "\(venue.id ?? "")" }) else {
            log.error("Failed to verify venue data or venue is not stored locally")
            return nil
        }
        return venue
    }
    
    /// Fetch the venue from the server
    /// - Returns: a `Venue` optinal object in case the server fails to find venue
    func fetchVenueRemote() async -> Venue? {
        guard let venue = event.venue,
              let venue = await session.fieldObserver.fetchVenue(id: "\(venue.id ?? "")") else {
            log.error("Failed to verify venue data to fetch remotely")
            return nil
        }
        session.venues.append(venue)
        return venue
    }
    
    var body: some View {
        Button(action:{ self.showDetails.toggle() }) {
            VStack {
                VStack(alignment: .leading){
                    HStack {
                        Image(imageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(radius: 10, corners: .allCorners)
                        VStack(alignment: .leading){
                            Text(title)
                                .font(.custom("Helvetica-Nue", size: 20))
                                .bold()
                                .frame(height: 20)
                                .padding(.top)
                                .foregroundColor(.primary)
                            
                            Text(venue.name)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .redacted(reason: venueState != .success ? .placeholder : [])
                            Spacer()
                            if event.type == "tournament" {
                                Text("Tournament")
                                    .font(.caption)
                                    .padding(.bottom)
                                    .foregroundStyle(Color("color-tert"))
                            }
                        }
                        Spacer()
                        _TrailingView(event: $event)
                    }
                }.padding(.horizontal)
            }.frame(height: 100)
        }
        .clipShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
        }
        .fullScreenCover(isPresented: $showDetails) {
            EventView(event: event)
                .presentationDetents([.large])
        }
        .task {
            await fetchVenue()
        }
    }
}

/// Trailing view for Event view.
/// Contains the start date and time and participants view.
struct _TrailingView: View {
    
    @Binding var event: Event
    
    var participantsCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        return participants.count
    }
    
    var minParticipantsCount: Int {
        guard let minParticipants = event.minParticipants else {
            return 0
        }
        return minParticipants
    }
    
    var iconColor: Color {
        if (minParticipantsCount != 0) && (participantsCount != 0) && (participantsCount < minParticipantsCount) {
            return .yellow
        } else {
            return Color("color-prime")
        }
    }
    
    var body: some View {
        VStack (alignment: .trailing){
            if event.actualStopTime != nil {
                VStack (alignment: .trailing){
                    HStack {
                        Text("Ended")
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.gray)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            } else if event.actualStartTime != nil {
                VStack (alignment: .trailing){
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                        
                        Text("Live")
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.red)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            } else {
                VStack (alignment: .trailing){
                    Text(event.timeToString())
                        .bold()
                        .font(.callout)
                        .foregroundColor(.primary)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            }
            
            HStack {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(iconColor)
                Text("\(participantsCount)")
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    EventListItem(event: EVENTS[0])
        .environmentObject(SessionStore())
}
