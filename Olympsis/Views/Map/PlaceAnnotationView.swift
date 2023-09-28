//
//  PlaceAnnotationVIew.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/24/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct PlaceAnnotationView: View {
    
    @State var field: Field
    @State var showDetails = false
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack(spacing: 0) {
              Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)

              Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: 0, y: -5)
        }
    }
}

struct PlaceAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceAnnotationView(field: FIELDS[0]).environmentObject(SessionStore())
    }
}
