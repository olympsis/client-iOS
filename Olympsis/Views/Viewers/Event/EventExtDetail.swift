//
//  EventExtDetail.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import MapKit
import SwiftUI

// MARK: - FIELD/CLUB
struct EventExtDetail: View {
    @State var data: EventData?
    @EnvironmentObject private var session: SessionStore
    
    var isMember: Bool {
        guard let user = session.user,
              let clubs = user.clubs,
              clubs.count > 0,
              let club = data?.club,
              let id = club.id else {
            return false
        }
        return clubs.first(where: { $0 == id }) != nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let f = data?.field {
                VStack(alignment: .leading){
                    VStack(alignment: .leading){
                        Text(f.name)
                            .font(.title)
                            .bold()
                        Text(f.description)
                    }
                    VStack {
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: f.location.coordinates[1], longitude: f.location.coordinates[0]), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: .zoom, showsUserLocation: false, annotationItems: [f], annotationContent: { field in
                            MapMarker(coordinate: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), tint: Color("color-prime"))
                        }).frame(height: 270)
                            .cornerRadius(10)
                    }
                }
            }
            
            if let c = data?.club {
                VStack(alignment: .leading){
                    Text("Host")
                        .font(.title)
                        .foregroundColor(.primary)
                        .bold()
                    
                    Text(c.name ?? "")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    AsyncImage(url: URL(string:  GenerateImageURL(c.imageURL ?? ""))){ phase in
                        if let image = phase.image {
                            ZStack(alignment: .bottomTrailing) {
                                image
                                    .resizable()
                                    .frame(height: 300, alignment: .center)
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                                    .cornerRadius(10)
                                if !isMember {
                                    Menu{
                                        Button(action:{}){
                                            Label("View Details", systemImage: "ellipsis")
                                        }
                                        Button(action:{}){
                                            Label("Report an Issue", systemImage: "exclamationmark.shield")
                                        }
                                    }label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(maxWidth: .infinity, idealHeight: 80)
                                                .foregroundColor(Color("color-prime"))
                                            VStack {
                                                VStack {
                                                    Image(systemName: "ellipsis")
                                                        .resizable()
                                                        .frame(width: 25, height: 5)
                                                }.frame(height: 25)
                                                Text("More")
                                            }.foregroundColor(.white)
                                        }
                                    }.frame(width: 100, height: 80)
                                        .padding(.all, 10)
                                }
                            }
                            
                        } else if phase.error != nil {
                            ZStack {
                                Color(.gray) // Indicates an error.
                                    .cornerRadius(10)
                                    .frame(height: 300, alignment: .center)
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.white)
                            }
                        } else {
                            ZStack {
                                Color(.gray) // Indicates an error.
                                    .opacity(0.8)
                                    .cornerRadius(10)
                                    .frame(height: 300, alignment: .center)
                                ProgressView()
                            }
                        }
                    }
                    
                    Text(c.description ?? "")
                        .padding(.bottom)
                }
            }
        }.padding(.horizontal)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    EventExtDetail(data: EVENTS[0].data)
        .environmentObject(SessionStore())
}
