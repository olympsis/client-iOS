//
//  FilterView.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/30/25.
//

import MapKit
import SwiftUI

struct FilterView: View {
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private var fallbackLocation: MKCoordinateRegion {
        guard let user = session.user, let hometown = user.hometown else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.76553, longitude: -73.97770), latitudinalMeters: 4000, longitudinalMeters: 4000)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: hometown.coordinates[1], longitude: hometown.coordinates[0]), latitudinalMeters: 4000, longitudinalMeters: 4000)
    }
    
    /// Whether to render the tags section. Defaults to `true` so
    /// existing callers (events filter) are unchanged; callers like
    /// the venues / clubs filter pass `false` to omit the tags block.
    var showTags: Bool = true

    @Environment(SessionStore.self) private var session
    @Environment(SearchManager.self) private var manager
    @AppStorage("searchRadius") private var searchRadius: Double?

    // The user's chosen display unit (resolves to the device default until
    // they pick one in Locality settings). The radius is still stored
    // canonically in miles on `manager.radius`; this only changes how the
    // slider and label present it.
    @AppStorage(DistanceUnit.storageKey) private var distanceUnitRaw: String = ""
    private var distanceUnit: DistanceUnit { DistanceUnit.resolved(from: distanceUnitRaw) }
    
    private func updateMapRegion() {
        // Get the current center
        let center = LocationManager.shared.location ?? fallbackLocation.center
        
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
        let text = String(localized: "sports", table: "General")
        return manager.selectedSports.isEmpty ? text : "\(text) (\(manager.selectedSports.count))"
    }
    
    private var tagsHeaderString: String {
        let text = String(localized: "tags", table: "General")
        return manager.selectedTags.isEmpty ? text : "\(text) (\(manager.selectedTags.count))"
    }
    
    var body: some View {
        @Bindable var manager = manager
        
        ScrollView {
            
            Spacer(minLength: 15)
            
            VStack {
                Map(position: $cameraPosition) {
                    // Add a MapCircle for precise radius visualization
                    MapCircle(
                        center: LocationManager.shared.location ?? fallbackLocation.center,
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
                    Text("\(String(localized: "radius", table: "General")):")
                        .fontWeight(.medium)
                    Text(String(localized: "radius-sub-title", table: "General"))
                        .font(.callout)
                        .foregroundStyle(.gray)
                    HStack {
                        // The slider operates in the user's chosen unit but
                        // keeps `manager.radius` canonical in miles: the
                        // getter converts miles → display unit, the setter
                        // converts back and clamps to the 1...100 mile cap.
                        let radiusBinding = Binding<Double>(
                            get: { distanceUnit.value(fromMiles: manager.radius) },
                            set: { manager.radius = min(max(distanceUnit.miles(fromValue: $0), 1), 100) }
                        )
                        let radiusMax = distanceUnit.value(fromMiles: 100).rounded()

                        Slider(value: radiusBinding, in: 1...radiusMax, step: 1)
                            .tint(Color("color-prime"))
                        Text("\(Int(distanceUnit.value(fromMiles: manager.radius))) \(distanceUnit.abbreviation)")
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
                Text(String(localized: "sports-sub-title", table: "General"))
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
                                    RoundedRectangle(cornerRadius: 20).stroke(manager.isSportSelected(sport) ? Color.Brand.secondary : Color.Foreground.default.opacity(0.5), lineWidth: 2)
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
            
            if showTags {
                VStack(alignment: .leading) {
                    Text(tagsHeaderString)
                        .fontWeight(.medium)
                    Text(String(localized: "tags-sub-title", table: "General"))
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
                                        RoundedRectangle(cornerRadius: 20).stroke(manager.isTagSelected(tag) ? Color.Brand.secondary : Color.Foreground.default.opacity(0.5), lineWidth: 2)
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
    FilterView()
        .environment(SessionStore())
        .environment(SearchManager())
}
