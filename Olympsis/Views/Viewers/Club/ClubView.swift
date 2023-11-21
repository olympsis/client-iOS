//
//  ClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import MapKit
import SwiftUI

/// Club details are shown in this view. When you click to see details on a club list view you will reach this view to learn more about the club
struct ClubView: View {
    
    @State var club: Club
    @Environment(\.presentationMode) var presentationMode
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var trackingMode: MapUserTrackingMode = .none
    
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
    
    // url string of the club's image
    private var imageURL: String {
        guard let url = club.imageURL else {
            return "https://api.oylmpsis.com"
        }
        return GenerateImageURL(url)
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
        guard let members = club.members else {
            return 1
        }
        return members.count
    }
    
    // an array with a max count of 10 to display the images
    private var members: [Member] {
        guard let members = club.members else {
            return [Member]()
        }
        return Array(members.prefix(10))
    }
    
    // used to search region for map
    private var location: String {
        guard let city = club.city,
              let state = club.state else {
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
            ScrollView {
                VStack(alignment: .leading){
                    
                    // MARK: - Image
                    AsyncImage(url: URL(string: imageURL)){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(5)
                                    .frame(height: 250, alignment: .center)
                                    .clipped()
                                    .cornerRadius(10)
                            } else if phase.error != nil {
                                Color.red // Indicates an error.
                                    .cornerRadius(10)
                            } else {
                                Color.gray // Acts as a placeholder.
                                    .cornerRadius(10)
                            }
                    }.frame(height: 250, alignment: .center)
                        .padding(.horizontal, 5)
                    
                    
                    // MARK: Details
                    VStack(alignment: .leading) {
                        HStack {
                            if isPublic {
                                Image(systemName: "globe.americas.fill")
                                    .foregroundStyle(Color("color-prime"))
                                Text("Public club")
                            } else {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color("color-prime"))
                                Text("Private club")
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
                                AsyncImage(url: URL(string: GenerateImageURL(m.data?.imageURL ?? "https://api.olympsis.com"))){ phase in
                                    if let image = phase.image {
                                            image // Displays the loaded image.
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50, alignment: .center)
                                                .clipped()
                                                .clipShape(Circle())
                                        } else if phase.error != nil {
                                            Circle()
                                                .foregroundStyle(.gray)
                                        } else {
                                            Circle()
                                                .foregroundStyle(.gray)
                                        }
                                }.frame(height: 50, alignment: .center)
                            }
                        }
                    }.padding(.horizontal)
                        .padding(.vertical)
                    
                    // MARK: - Organizations
                    if let org = club.data?.parent {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "building.fill")
                                    .foregroundStyle(Color("color-prime"))
                                Text("Parent Organization")
                                    .bold()
                                    .font(.callout)
                            }
                            HStack {
                                AsyncImage(url: URL(string: GenerateImageURL(org.imageURL ?? "https://api.olympsis.com"))){ phase in
                                    if let image = phase.image {
                                            image // Displays the loaded image.
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50, alignment: .center)
                                                .clipped()
                                                .clipShape(Circle())
                                        } else if phase.error != nil {
                                            Circle()
                                                .foregroundStyle(.gray)
                                        } else {
                                            Circle()
                                                .foregroundStyle(.gray)
                                        }
                                }.frame(height: 50, alignment: .center)
                                
                                Text(org.name ?? "Organization")
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
                            Text(location)
                                .bold()
                        }
                    }.padding(.horizontal)
                        .padding(.top)

                    Map(coordinateRegion: $region, interactionModes: .zoom, showsUserLocation: false, userTrackingMode: $trackingMode, annotationItems: markers) { p in
                        MapPin(coordinate: CLLocationCoordinate2D(latitude: p.lat, longitude: p.lon), tint: .red)
                    }.padding(.horizontal)
                        .frame(height: 200)

                }.navigationTitle(name)
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
