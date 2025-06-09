//
//  FilterView.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/30/25.
//

import MapKit
import SwiftUI

struct FilterView: View {
    @Bindable var manager: SearchManager
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private var fallbackLocation: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.76553, longitude: -73.97770), latitudinalMeters: 4000, longitudinalMeters: 4000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]), latitudinalMeters: 4000, longitudinalMeters: 4000)
    }
    
    @Environment(SessionStore.self) private var session
    
    @AppStorage("searchRadius") private var searchRadius: Double?
    
    private func updateMapRegion() {
        // Get the current center
        let center = session.locationManager.location ?? fallbackLocation.center
        
        // Calculate the span to show the radius with padding
        let radiusInDegrees = (manager.radius * 1.5) / 69.2  // Convert meters to degrees with 50% padding
        
        // Account for longitude distortion at different latitudes
        let latitudinalPadding = radiusInDegrees
        let longitudinalPadding = radiusInDegrees / cos(center.latitude * .pi / 180.0)
        
        let newRegion = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: latitudinalPadding * 1.5,
                longitudeDelta: longitudinalPadding * 1.5
            )
        )
        
        manager.mapRegion = newRegion
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(newRegion)
        }
    }
    
    private var sportsHeaderString: String {
        return manager.selectedSports.isEmpty ? "Sports" : "Sports (\(manager.selectedSports.count))"
    }
    
    private var tagsHeaderString: String {
        return manager.selectedTags.isEmpty ? "Tags" : "Tags (\(manager.selectedTags.count))"
    }
    
    var body: some View {
        ScrollView {
            
            Spacer(minLength: 15)
            
            VStack {
                Map(position: $cameraPosition) {
                    // Add a MapCircle for precise radius visualization
                    MapCircle(
                        center: session.locationManager.location ?? fallbackLocation.center,
                        radius: manager.radius * 1609.34  // Convert miles to meters (1 mile = 1609.34 meters)
                    )
                    .strokeStyle(style: .init(lineWidth: 2, dash: [6, 6]))
                    .foregroundStyle(.blue.opacity(0.3))
                    
                    UserAnnotation()
                }
                .disabled(true)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 10)
                .frame(height: 250)
                .onChange(of: manager.radius) { _, newValue in
                    withAnimation {
                        updateMapRegion()
                    }
                }
                .onAppear {
                    updateMapRegion()
                }
                .padding(.bottom)
                
                
                VStack(alignment: .leading) {
                    Text("Radius:")
                        .fontWeight(.medium)
                    Text("Searching for clubs near you")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    HStack {
                        Slider(value: $manager.radius, in: 1...100, step: 1)
                            .tint(Color("color-prime"))
                        Text("\(Int(manager.radius)) miles")
                            .padding(.trailing)
                            .onChange(of: manager.radius) { _, newValue in
                                searchRadius = newValue
                            }
                    }
                }
            }
            .padding(.top, 5)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.Background.secondary, lineWidth: 2)
            }
            .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text(sportsHeaderString)
                    .fontWeight(.medium)
                Text("Only include the sports you like")
                    .font(.callout)
                    .foregroundStyle(.gray)

                WrappingHStack(alignment: .bottomLeading) {
                    ForEach(manager.sports, id: \.name) { sport in
                        Button(action: { manager.selectSport(sport) }) {
                            Text("\(sport.name.capitalized.replacingOccurrences(of: "-", with: " "))")
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(.regularMaterial)
                                .background(Color.gray.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .background {
                                    RoundedRectangle(cornerRadius: 20).stroke(manager.isSportSelected(sport) ? Color.Brand.secondary : Color.foreground.opacity(0.5), lineWidth: 2)
                                }
                        }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.Background.secondary, lineWidth: 2)
            }
            .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text(tagsHeaderString)
                    .fontWeight(.medium)
                Text("Add some keywords to find your club!")
                    .font(.callout)
                    .foregroundStyle(.gray)

                WrappingHStack(alignment: .bottomLeading) {
                    ForEach(manager.tags, id: \.name) { tag in
                        Button(action: { manager.selectTag(tag) }) {
                            Text("\(tag.name.capitalized.replacingOccurrences(of: "-", with: " "))")
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(.regularMaterial)
                                .background(Color.gray.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .background {
                                    RoundedRectangle(cornerRadius: 20).stroke(manager.isTagSelected(tag) ? Color.Brand.secondary : Color.foreground.opacity(0.5), lineWidth: 2)
                                }
                        }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.Background.secondary, lineWidth: 2)
            }
            .padding(.horizontal, 10)
        }
        .task {
            #if targetEnvironment(simulator)
            manager.tags = TAGS_TEMP
            manager.sports = SPORTS_TEMP
            #endif
            
            manager.tags = session.tags
            manager.sports = session.sports
        }
    }
}

#Preview {
    FilterView(manager: SearchManager())
        .environment(SessionStore())
}
