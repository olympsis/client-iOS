//
//  LocationPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/28/24.
//

import SwiftUI

struct LocationPicker: View {
    
    @State private var countries = [String]()
    
    var body: some View {
        VStack {
            ForEach(countries, id: \.self) { country in
                Text(country)
            }
        }
    }
}

#Preview {
    LocationPicker()
}
