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
struct ClubDetailView: View {
    
    var club: Club
    @State private var camera = MapCameraPosition.camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(
            latitude: 37.3347302, longitude: -122.0089189
        ), distance: 1000 )
    )
    
    func updatePosition() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString("\(club.city), \(club.state) \(club.country)") { (placemarks, error) in
            if let placemark = placemarks?.first, let location = placemark.location {
                self.camera = MapCameraPosition.camera(
                    MapCamera(centerCoordinate: location.coordinate, distance: 10000)
                )
            }
        }
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
        return club.visibility == "public" ? true : false
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
        return club.city + " " + club.state
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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                
                // MARK: - Image
                ClubLogoBanner()
                    .environment(club)
                
                // MARK: Details
                VStack(alignment: .leading) {
                    HStack {
                        if isPublic {
                            Image(systemName: "globe.americas.fill")
                            Text(String(localized: "public-club", table: "General"))
                                .font(.callout)
                        } else {
                            Image(systemName: "lock.fill")
                            Text(String(localized: "private-club", table: "General"))
                                .font(.callout)
                        }
                    }
                    HStack {
                        Text(String(localized: "\(membersCount) member", table: "General"))
                    }
                    
                    HStack(spacing: -10) {
                        ForEach(members, id: \.id) { m in
                            UserBadgeView(size: .small, imageURL: URL(string: m.user?.imageURL ?? ""))
                        }
                    }
                }.padding()
                
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
                    }.padding([.horizontal, .bottom])
                }
                
                // MARK: - Club Tags
                VStack(alignment: .leading) {
                    Text(String(localized: "club-tags", table: "Groups"))
                        .font(.title2)
                        .bold()
                    
                    WrappingHStack(alignment: .bottomLeading) {
                        ForEach(club.tags, id: \.self) { tag in
                            TagView(tag: Tag(name: tag))
                        }
                    }
                    
                }.padding([.horizontal, .bottom])
                
                // MARK: - Description
                VStack(alignment: .leading) {
                    Text(String(localized: "about", table: "General"))
                        .font(.title2)
                        .bold()
                    ExpandableTextView(text: description)
                }.padding(.horizontal)
                
                
                // MARK: - Location Map
                VStack {
                    HStack {
                        Text(String(localized: "located-in", table: "Groups"))
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                            .bold()
                    }
                }.padding([.top, .horizontal])
                
                Map(position: $camera, interactionModes: .zoom)
                    .frame(height: 200)
                    .padding(.bottom)
                
                HStack {
                    Text("\(String(localized: "established", table: "Groups")) ")
                        .bold()
                    +
                    Text(calculateTimeAgo(from: club.createdAt))
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle(club.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            updatePosition()
        }
    }
}

#Preview {
    ClubDetailView(club: CLUBS[0])
}
