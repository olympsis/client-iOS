//
//  EventLocation.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI
import Kingfisher

struct EventLocation: View {

    @Binding var venues: [Venue]
    @Environment(Event.self) private var event: Event

    /// Map snapshot image URLs keyed by VenueDescriptor hash for quick lookup
    @State private var snapshotURLs: [Int: URL] = [:]

    private let snapshotService = SnapshotService()

    private var venueDescriptors: [VenueDescriptor] {
        return event.venues
    }

    /// Fetches all venue snapshot URLs in parallel using a TaskGroup
    private func fetchSnapshots() async {
        await withTaskGroup(of: (Int, URL?).self) { group in
            for descriptor in venueDescriptors {
                let key = descriptor.hashValue
                guard let coordinates = descriptor.location?.coordinates,
                      coordinates.count >= 2 else { continue }

                // GeoJSON is [longitude, latitude], API expects "lat,long"
                let center = "\(coordinates[1]),\(coordinates[0])"

                group.addTask {
                    do {
                        let urlString = try await snapshotService.getMapSnapshotURL(name: center)
                        return (key, generateImageURL(urlString))
                    } catch {
                        // Snapshot fetch failed — will show placeholder
                    }
                    return (key, nil)
                }
            }

            for await (key, url) in group {
                if let url {
                    snapshotURLs[key] = url
                }
            }
        }
    }
    
    /// Builds a subtitle string: full address if available, otherwise raw coordinates
    private func subtitle(for descriptor: VenueDescriptor) -> String {
        if let address = descriptor.fullAddress, !address.isEmpty {
            return address
        }
        if let coordinates = descriptor.location?.coordinates, coordinates.count >= 2 {
            return String(format: "%.4f, %.4f", coordinates[1], coordinates[0])
        }
        return ""
    }
    
    var body: some View {
        if !venues.isEmpty {
            Group {
                HStack {
                    Text(String(localized: "new-event-location-title", table: "Events"))
                        .font(.title2)
                        .bold()
                }
                ForEach(venueDescriptors, id: \.self) { descriptor in
                    VStack(alignment: .leading, spacing: 4) {
                        // Snapshot image or loading placeholder
                        if let url = snapshotURLs[descriptor.hashValue] {
                            KFImage(url)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.quaternary)
                                        .frame(height: 100)
                                        .overlay {
                                            ProgressView()
                                        }
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(radius: 10, corners: .allCorners)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.quaternary)
                                .frame(height: 100)
                                .overlay {
                                    ProgressView()
                                }
                        }
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .imageScale(.large)
                            
                            VStack(alignment: .leading) {
                                // Venue name
                                Text(descriptor.name ?? "Venue")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                
                                // Full address or coordinates fallback
                                let sub = subtitle(for: descriptor)
                                if !sub.isEmpty {
                                    Text(sub)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .id(7)
            .padding(.horizontal)
            .task {
                await fetchSnapshots()
            }
        }
    }
}

#Preview {
    EventLocation(venues: .constant([]))
        .environment(EVENTS[0])
}
