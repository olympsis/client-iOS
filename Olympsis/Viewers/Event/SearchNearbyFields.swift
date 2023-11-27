//
//  SearchNearbyFields.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/12/23.
//

import MapKit
import SwiftUI

struct SearchNearbyFields: View {
    
    @Binding var selectedLandmark: MKMapItem
    @State private var searchText: String = ""
    @State private var showCancel: Bool = false
    @State private var landmarks: [MKMapItem] = [MKMapItem]()
    
    @State var locationService = LocationObserver()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    SearchBar(text: $searchText, onCommit: {
                        showCancel = false
                        Task {
                            landmarks = await locationService.searchPointOfIntrests(searchText: searchText)
                        }
                    }).onTapGesture {
                            if !showCancel {
                                showCancel = true
                            }
                        }
                    .frame(maxWidth: SCREEN_WIDTH-10, maxHeight: 40)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    .padding(.top)
                    if showCancel {
                        Button(action:{
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            showCancel = false
                        }){
                            Text("Cancel")
                                .foregroundColor(.gray)
                                .frame(height: 40)
                                .padding(.top)
                        }.padding(.trailing)
                    }
                }
                
                ForEach($landmarks, id: \.self) { landmark in
                    Button(action: {
                        selectedLandmark = landmark.wrappedValue
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        LandmarkView(landmark: landmark)
                    }
                    
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{ self.presentationMode.wrappedValue.dismiss() }){
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .navigationTitle("Nearby Fields")
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color("primary-color"))
        }
    }
}

struct SearchNearbyFields_Previews: PreviewProvider {
    static var previews: some View {
        SearchNearbyFields(selectedLandmark: .constant(MKMapItem()))
    }
}
