//
//  ProfileHometownPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/24.
//

import os
import MapKit
import SwiftUI

struct ProfileHometownPicker: View {
    
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    @State private var pin: CLLocationCoordinate2D?
    
    @GestureState private var isLongPressing = false
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Text("Done")
                }
            }.padding(.horizontal)
            HStack {
                Spacer()
                Text("Press and hold to drop a pin")
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                Spacer()
            }
            HStack {
                if (pin != nil) {
                    Text("\(city), \(state) (\(country))")
                }
            }
            MapReader { proxy in
                Map {
                    if (pin != nil) {
                        MapCircle(center: pin!, radius: CLLocationDistance(integerLiteral: 2000))
                            .foregroundStyle(Color("color-prime").opacity(0.5))
                            .stroke(Color("color-prime"), lineWidth: 4)
                            .mapOverlayLevel(level: .aboveLabels)
                    }
                }.gesture(DragGesture())
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5, maximumDistance: 0)
                            .sequenced(before: SpatialTapGesture(coordinateSpace: .local))
                            .updating($isLongPressing) { currentState, gestureState, transaction in
                                
                            }
                            .onEnded { value in
                                switch value {
                                case let .second(_, tapValue):
                                    guard let point = tapValue?.location else {
                                        print("Unable to retreive tap location from gesture data.")
                                        return
                                    }
                                    
                                    guard let coordinates = proxy.convert(point, from: .local) else {
                                        print("Unable to convert local point to coordinate on map.")
                                        return
                                    }
                                    
                                    withAnimation {
                                        pin = coordinates
                                        self.viewModel.hometown = pin
                                        getPlacemark(from: coordinates) { placemark in
                                            if let placemark = placemark {
                                                let city = placemark.locality ?? ""
                                                let state = placemark.administrativeArea ?? ""
                                                let country = placemark.country ?? ""
                                                
                                                self.city = city
                                                self.state = state
                                                self.country = country
                                                
                                                self.viewModel.city = city
                                                self.viewModel.state = state
                                                self.viewModel.country = country
                                            } else {
                                                print("Unable to get placemark information")
                                            }
                                        }
                                    }
                                default: return
                                }
                            }
                    )
            }
        }
    }
}

#Preview {
    ProfileHometownPicker()
        .environmentObject(ProfileViewModel())
}
