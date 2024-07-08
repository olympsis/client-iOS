//
//  RunningMapView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/6/24.
//

import MapKit
import SwiftUI

struct RunningMap: View {
    var body: some View {
        Map()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .frame(height: 160)
    }
}

#Preview {
    RunningMap()
}
