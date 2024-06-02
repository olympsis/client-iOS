//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import MapKit
import SwiftUI
import Kingfisher

/// Club details are shown in this view. When you click to see details on a club list view you will reach this view to learn more about the club
struct ClubView: View {
    
    @StateObject var club: Club
    @Environment(\.presentationMode) var presentationMode
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var trackingMode: MapUserTrackingMode = .none
    
    init(club: Club) {
        self._club = StateObject(wrappedValue: club)
    }
    
    // club name
    private var name: String {
        guard let n = club.name else {
            return "name"
        }
        return n
    }
    
    // club description
    private var description: String {
        guard let d = club.description else {
            return ""
        }
        return d
    }
    
    // club's visibility
    private var isPublic: Bool {
        guard let visibility = club.visibility else {
            return true
        }
        return visibility == "public" ? true : false
    }
    
    // number of members in the club
    private var membersCount: Int {
        return club.members.count
    }
    
    // an array with a max count of 10 to display the images
    private var members: [Member] {
        return Array(club.members.prefix(10))
    }
    
    // used to search region for map
    private var location: String {
        guard let city = club.city,
              let state = club.state else {
            return "Unknown, Location"
        }
        return city + " " + state
    }
    
    private var hasParent: Bool {
        guard let parent = club.parent else {
            return false
        }
        return (parent.id != nil) ? true : false
    }
    
    private var parentLogoURL: URL? {
        guard let parent = club.parent,
              let logo = parent.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    private var parentName: String {
        guard let parent = club.parent,
              let name = parent.name else {
            return "Organization"
        }
        return name
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
                    
                    // MARK: - Image
                    ClubBanner()
                        .environmentObject(club)
                    
                    // MARK: Details
                    VStack(alignment: .leading) {
                        HStack {
                            if isPublic {
                                Image(systemName: "globe.americas.fill")
                                    .foregroundStyle(Color("color-prime"))
                                Text("Public club")
                                    .font(.callout)
                            } else {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color("color-prime"))
                                Text("Private club")
                                    .font(.callout)
                            }
                        }
                        HStack {
                            if membersCount > 1 {
                                Text("\(membersCount)")
                                    .foregroundStyle(Color("color-prime"))
                                    .bold()
                                Text("members")
                            } else {
                                Text("\(membersCount)")
                                    .foregroundStyle(Color("color-prime"))
                                    .bold()
                                Text("member")
                            }
                        }
                        
                        HStack(spacing: -20) {
                            ForEach(members, id: \.id) { m in
                                AsyncImage(url: URL(string: GenerateImageURL(m.user?.imageURL ?? "https://api.olympsis.com"))){ phase in
                                    if let image = phase.image {
                                            image // Displays the loaded image.
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50, alignment: .center)
                                                .clipped()
                                                .clipShape(Circle())
                                        } else if phase.error != nil {
                                            ZStack {
                                                Circle()
                                                    .foregroundStyle(.gray)
                                                Image(systemName: "person.fill")
                                                    .imageScale(.large)
                                                    .foregroundStyle(.white)
                                            }
                                        } else {
                                            ZStack {
                                                Circle()
                                                    .foregroundStyle(.gray)
                                                Image(systemName: "person.fill")
                                                    .imageScale(.large)
                                                    .foregroundStyle(.primary)
                                            }
                                        }
                                }.frame(height: 50, alignment: .center)
                            }
                        }
                    }.padding(.horizontal)
                        .padding(.vertical)
                    
                    // MARK: - Organizations
                    if hasParent {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "building.fill")
                                    .foregroundStyle(Color("color-prime"))
                                Text("Parent Organization")
                                    .bold()
                                    .font(.callout)
                            }
                            HStack {
                                if let url = parentLogoURL {
                                    KFImage(url)
                                        .resizable()
                                        .placeholder {
                                            ZStack(alignment: .center) {
                                                Circle()
                                                    .foregroundStyle(.gray)
                                                    .frame(width: 50, height: 50, alignment: .center)
                                                ProgressView()
                                            }
                                        }
                                        .scaledToFill()
                                        .frame(width: 50, height: 50, alignment: .center)
                                        .clipped()
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .foregroundStyle(.gray)
                                        .frame(width: 50, height: 50, alignment: .center)
                                }
                                
                                Text(parentName)
                                    .font(.callout)
                            }
                        }.padding(.horizontal)
                            .padding(.bottom)
                    }
                    
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
                    }
                    .frame(height: 200)
                    .padding(.bottom)
                    
                    HStack {
                        if let createdAt = club.createdAt {
                            Text("Established ")
                                .bold()
                            +
                            Text(timeAgo(from: createdAt))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .navigationTitle(name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ClubView(club: CLUBS[0])
}
