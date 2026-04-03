//
//  NewEventCustomLocation.swift
//  Olympsis
//
//  Created by Joel Joseph on 9/3/25.
//

import SwiftUI

struct NewEventCustomLocation: View {
    
    @State private var name: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @Environment(CustomLocationViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
            if viewModel.selectedCoordinate != nil {
                if let location = viewModel.locationInfo {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                viewModel.locationInfo?.name = name
                                dismiss()
                            }) {
                                Text(String(localized: "done", table: "General"))
                                    .fontWeight(.bold)
                            }
                        }
                        HStack(alignment: .center) {
                            
                            VStack(alignment: .leading, spacing: 20) {
                                TextField(String(localized: "set-custom-location-name", table: "Events"), text: $name)
                                Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                            }
                            
                            Button(action: { viewModel.clearPin() }) {
                                Text(String(localized: "clear", table: "General"))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.red)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(style: StrokeStyle(lineWidth: 1))
                                            .opacity(0.5)
                                    }
                            }
                        }
                        .padding(.all)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .opacity(0.12)
                        }
                        .padding(.bottom)
                    }
                } else {
                    ProgressView()
                }
            } else {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(String(localized: "tap-anywhere-text", table: "Events"))
                        .font(.callout)
                        .fontWeight(.medium)
                        
                    Spacer()
                }
                .foregroundStyle(.gray)
            }
        }.padding([.top, .horizontal])
            
        CustomLocationPicker()
            .environment(viewModel)
            .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
    }
}

#Preview {
    NewEventCustomLocation()
        .environment(CustomLocationViewModel())
}
