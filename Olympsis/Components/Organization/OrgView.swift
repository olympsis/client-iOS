//
//  OrgView.swift
//  Olympsis
//
//  Created by Joel on 12/12/23.
//

import MapKit
import SwiftUI

struct OrgView: View {
    
    @State var organization: Organization
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var trackingMode: MapUserTrackingMode = .none
    @Environment(\.dismiss) private var dismiss
    
    // organization name
    private var name: String {
        guard let n = organization.name else {
            return "name"
        }
        return n
    }
    
    // organization imageurl
    private var imageURL: String {
        guard let url = organization.imageURL else {
            return "https://api.oylmpsis.com"
        }
        return GenerateImageURL(url)
    }
    
    // organization description
    private var description: String {
        guard let d = organization.description else {
            return ""
        }
        return d
    }
    
    // used to search region for map
    private var location: String {
        guard let city = organization.city,
              let state = organization.state else {
            return "Unknown, Location"
        }
        return city + " " + state
    }
    
    // wrapper for map pin
    struct Pin: Identifiable {
        let id = UUID()
        let lon: Double
        let lat: Double
    }
    
    // pin to mark location on map
    var markers: [Pin] {
        let geocoder = CLGeocoder()
        var pins = [Pin]()

        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let placemark = placemarks?.first, let location = placemark.location {
                let p = Pin(lon: location.coordinate.longitude, lat: location.coordinate.latitude)
                pins.append(p)
                region.center = location.coordinate
            }
        }
        return pins
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    
                    // MARK: - Image
                    AsyncImage(url: URL(string: imageURL)){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: SCREEN_WIDTH, height: 250, alignment: .center)
                                    .clipped()
                                    
                            } else if phase.error != nil {
                                Rectangle()
                                    .frame(width: SCREEN_WIDTH, height: 250, alignment: .center)
                                    .foregroundColor(.red)
                            } else {
                                Rectangle()
                                    .frame(width: SCREEN_WIDTH, height: 250, alignment: .center)
                                    .foregroundColor(.gray)
                            }
                    }.frame(height: 250, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    
                    // MARK: Details
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "building.fill")
                                .foregroundStyle(Color("color-prime"))
                            Text("Organization")
                                .font(.callout)
                        }
                    }.padding(.horizontal)
                        .padding(.vertical)
                    
                    // MARK: - Description
                    VStack(alignment: .leading) {
                        Text("About")
                            .font(.title2)
                            .bold()
                        Text(description)
                            .font(.callout)
                    }.padding(.horizontal)
                    
                    
                    // MARK: - Location Map
                    VStack {
                        HStack {
                            Text("Located in")
                                .font(.caption)
                            Text(location)
                                .font(.caption)
                                .bold()
                        }
                    }.padding(.horizontal)
                        .padding(.top)

                    Map(coordinateRegion: $region, interactionModes: .zoom, showsUserLocation: false, userTrackingMode: $trackingMode, annotationItems: markers) { p in
                        MapPin(coordinate: CLLocationCoordinate2D(latitude: p.lat, longitude: p.lon), tint: .red)
                    }.frame(height: 200)
                        .padding(.bottom, 40)

                }.navigationTitle(name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    OrgView(organization: ORGANIZATIONS[0])
}
