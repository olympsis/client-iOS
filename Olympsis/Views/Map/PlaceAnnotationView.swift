//
//  PlaceAnnotationVIew.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/24/22.
//

import SwiftUI

struct PlaceAnnotationView: View {
    @State var field: Field
    @Binding var events: [Event]
    @State var showDetails = false
    var body: some View {
        VStack(spacing: 0) {
              Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)

              Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: 0, y: -5)
        }.onTapGesture {
            withAnimation(.easeInOut) {
                self.showDetails.toggle()
            }
          }
        .fullScreenCover(isPresented: $showDetails) {
            FieldDetailView(field: field, events: events)
        }
    }
}

struct PlaceAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceAnnotationView(field: FIELDS[0], events: .constant([Event]()))
    }
}
