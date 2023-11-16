//
//  MapOptions.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import SwiftUI

struct MapOptions: View {
    
    @State var availableSports:[String]
    @State private var selectedSports: [String] = [String]()
    @State private var status: LOADING_STATE = .pending
    @State private var sliderValue = 5.0
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("searchRadius") var radius: Double? // search radius for fields/events in meters
    
    func updateSports(sport:String){
        selectedSports.contains(where: {$0 == sport}) ? selectedSports.removeAll(where: {$0 == sport}) : selectedSports.append(sport)
    }
    
    func isSelected(sport:String) -> Bool {
        return selectedSports.contains(where: {$0 == sport})
    }
    
    func NewSearch() async {
        guard let location = session.locationManager.location else {
            return
        }
        await session.getNearbyData(location: location)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 5)
                .foregroundColor(.gray)
                .opacity(0.3)
                .padding(.top, 5)
            VStack(alignment: .leading) {
                Text("Search Radius:")
                    .bold()
                    .padding(.top, 20)
                HStack {
                    Slider(value: $sliderValue, in: 5...100, step: 5)
                        .tint(Color("color-prime"))
                    Text("\(Int(sliderValue)) miles")
                        .padding(.trailing)
                        .onChange(of: sliderValue) { newValue in
                            radius = milesToMeters(radius: sliderValue)
                        }
                }
                Text("Sports:")
                    .bold()
                ForEach($availableSports, id: \.self){ _sport in
                    HStack {
                        Button(action: {updateSports(sport: _sport.wrappedValue)}){
                            isSelected(sport: _sport.wrappedValue) ? Image(systemName: "circle.fill")
                                .foregroundColor(Color("color-prime")).imageScale(.medium) : Image(systemName:"circle")
                                .foregroundColor(.primary).imageScale(.medium)
                        }
                        Text(_sport.wrappedValue)
                            .font(.body)
                        Spacer()
                    }.padding(.top)
                }
                
                HStack {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Text("Cancel")
                            .bold()
                            .foregroundColor(.red)
                    }.frame(height: 40)
                    
                    Spacer()
                    
                    Button(action:{
                        Task {
                            await MainActor.run {
                                self.status = .loading
                            }
                            await NewSearch()
                            await MainActor.run {
                                self.status = .success
                            }
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 40)
                                .foregroundColor(Color("color-prime"))
                            LoadingButton(text: "Search", width: 100, status: $status)
                        }
                    }.padding(.trailing)
                }.padding(.top)
            }.padding(.leading)
                .task {
                    guard let radiusValue = radius else {
                        return
                    }
                    await MainActor.run {
                        sliderValue = metersToMiles(radius: radiusValue)
                    }
                }
        }
    }
}

struct MapOptions_Previews: PreviewProvider {
    static var previews: some View {
        MapOptions(availableSports: ["Soccer", "Basketball", "Pickleball"])
    }
}
