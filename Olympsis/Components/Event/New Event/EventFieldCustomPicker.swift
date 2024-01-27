//
//  EventFieldCustomPicker.swift
//  Olympsis
//
//  Created by Joel on 1/18/24.
//

import SwiftUI
import MapKit

struct EventFieldCustomPicker: View {
    
    enum STATE {
        case pending
        case searching
        case completed
        case selected
    }
    
    @Binding var selected: SelectedCustomField
    @State private var text: String = ""
    @State private var locations: [CustomField] = [CustomField]()
    @State private var status: LOADING_STATE = .pending
    @State private var state: STATE = .pending
    @State private var selectedLocation: CustomField?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var trackingMode: MapUserTrackingMode = .none
    
    @FocusState private var keyBoardFocus: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session:SessionStore
    
    func search() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = session.locationManager.region
        request.resultTypes = .pointOfInterest
        
        let searchRequest = MKLocalSearch(request: request)
        do {
            state = .searching
            let results = try await searchRequest.start()
            let points = results.mapItems
            if points.count > 100 {
                let reduced = points.dropLast(points.count - 100)
                self.locations = reduced.map({ CustomField(item: $0) })
            } else {
                self.locations = points.map({ CustomField(item: $0) })
            }
            state = .completed
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getLocality(_ item: MKMapItem) -> String {
        guard let ad = item.placemark.administrativeArea else {
            return item.placemark.country ?? ""
        }
        guard let country = item.placemark.country else {
            return ""
        }
        return "\(ad), \(country)"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Location name", text: $text)
                    .padding(.leading)
                    .modifier(InputField())
                    .focused($keyBoardFocus)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            keyBoardFocus = false
                            await search()
                        }
                    }
                
                Button(action: {
                    Task {
                        keyBoardFocus = false
                        await search()
                    }
                }) {
                    LoadingButton(image: Image(systemName: "magnifyingglass"), width: 50, height: 50, status: $status)
                }
            }.padding(.horizontal)
            switch state {
            case .searching:
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            case .completed, .pending:
                ScrollView {
                    ForEach(locations) { loc in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(loc.item.name ?? "Point of Interest")
                                    .font(.title3)
                                Text(getLocality(loc.item))
                                    .foregroundStyle(.gray)
                            }.padding(.horizontal)
                                .padding(.vertical)
                            Spacer()
                        }.onTapGesture {
                            selectedLocation = loc
                            let center = CLLocationCoordinate2D(latitude: loc.item.placemark.coordinate.latitude, longitude: loc.item.placemark.coordinate.longitude)
                            region.center = center
                            state = .selected
                        }
                    }
                }
            case .selected:
                VStack(alignment: .leading) {
                    Text(selectedLocation?.item.name ?? "Point of Interest")
                        .font(.title3)
                    Text(getLocality(selectedLocation!.item))
                        .foregroundStyle(.gray)
                }.padding(.horizontal)
                    .padding(.vertical)
                Map(coordinateRegion: $region, interactionModes: .zoom, showsUserLocation: true, userTrackingMode: $trackingMode, annotationItems: [selectedLocation!], annotationContent: { loc in
                    MapPin(coordinate: selectedLocation?.item.placemark.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                })
                
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            guard let loc = selectedLocation,
                                  let name = loc.item.name else {
                                return
                            }
                            let coordinates = loc.item.placemark.coordinate
                            let location = GeoJSON(type: "Point", coordinates: [Double(coordinates.longitude), Double(coordinates.latitude)])
                            let desc = FieldDescriptor(type: "external", id: nil, name: name, location: location)
                            
                            Task { @MainActor in
                                selected.field = desc
                                selected.administrativeArea = loc.item.placemark.administrativeArea ?? ""
                                selected.subAdministrativeArea = loc.item.placemark.subAdministrativeArea ?? ""
                                selected.country = loc.item.placemark.country ?? ""
                            }
                            
                            dismiss()
                        }
                    }) {
                        SimpleButtonLabel(text: "Select Location")
                    }
                    Spacer()
                }.padding(.vertical)
            }
        }.padding(.top)
    }
}

#Preview {
    EventFieldCustomPicker(selected: .constant(SelectedCustomField(field: nil)))
        .environmentObject(SessionStore())
}
