//
//  OrgView.swift
//  Olympsis
//
//  Created by Joel on 12/12/23.
//

import MapKit
import SwiftUI

struct OrgDetailView: View {
    
    @StateObject var organization: Organization
    @State private var camera = MapCameraPosition.camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(
            latitude: 37.3347302, longitude: -122.0089189
        ), distance: 1000 )
    )
    @Environment(\.dismiss) private var dismiss
    
    init(organization: Organization) {
        self._organization = StateObject(wrappedValue: organization)
    }
    
    // organization name
    private var name: String {
        guard let n = organization.name else {
            return "name"
        }
        return n
    }
    
    // organization imageurl
    private var imageURL: String {
        guard let url = organization.logo else {
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
    
    func updatePosition() {
        let geocoder = CLGeocoder()
        
        if let city = organization.city,
           let state = organization.state,
           let country = organization.country {
            geocoder.geocodeAddressString("\(city), \(state) \(country)") { (placemarks, error) in
                if let placemark = placemarks?.first, let location = placemark.location {
                    self.camera = MapCameraPosition.camera(
                        MapCamera(centerCoordinate: location.coordinate, distance: 10000)
                    )
                }
            }
        }
    }
    
    func timeAgo(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let now = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month, .day], from: date, to: now)

        if let years = components.year, years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        } else if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else {
            return "Today"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    
                    OrgBanner()
                        .environmentObject(organization)
                    
                    
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

                    Map(position: $camera, interactionModes: .pan)
                        .frame(height: 200)
                        .padding(.bottom)
                    
                    HStack {
                        Text("Established ")
                            .bold()
                        +
                        Text(calculateTimeAgo(from: organization.createdAt))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)

                }
                .navigationTitle(name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }.background(Color.Background.primary)
        }.onAppear {
            updatePosition()
        }
    }
}

#Preview {
    OrgDetailView(organization: ORGANIZATIONS[0])
}
