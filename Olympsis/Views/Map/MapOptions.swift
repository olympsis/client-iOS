//
//  MapOptions.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import SwiftUI
import CoreLocation

struct MapOptions: View {
    
    @State var availableSports:[SPORTS]
    @State var selectedSports: [String] = [String]()
    @State private var status: LOADING_STATE = .pending
    @State private var sliderValue = 5.0
    
    @EnvironmentObject private var router: EventRouter
    @EnvironmentObject private var session: SessionStore
    
    @AppStorage("searchRadius") private var radius: Double? // search radius for fields/events in meters
    
    func updateSports(sport:String){
        selectedSports.contains(where: {$0 == sport}) ? selectedSports.removeAll(where: {$0 == sport}) : selectedSports.append(sport)
    }
    
    func isSelected(sport:String) -> Bool {
        return selectedSports.contains(where: {$0 == sport})
    }
    
    func NewSearch() async {
        if let location = session.locationManager.location {
            await session.getNearbyData(location: location, selectedSports: selectedSports)
            return
        } else {
            guard let user = session.user,
                let hometown = user.hometown else {
                return
            }
            await session.getNearbyData(location: CLLocationCoordinate2D(latitude: hometown[0], longitude: hometown[1]), selectedSports: selectedSports)
        }
    }
    
    var body: some View {
        VStack {            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Search Radius:")
                        .bold()
                        .padding(.top, 20)
                    HStack {
                        Slider(value: $sliderValue, in: 5...100, step: 5)
                            .tint(Color("color-prime"))
                        Text("\(Int(sliderValue)) miles")
                            .padding(.trailing)
                            .onChange(of: sliderValue) { _, newValue in
                                radius = milesToMeters(radius: sliderValue)
                            }
                    }
                    Text("Sports:")
                        .bold()
                    ForEach($availableSports, id: \.self){ _sport in
                        HStack {
                            Button(action: { updateSports(sport: _sport.wrappedValue.rawValue) }){
                                isSelected(sport: _sport.wrappedValue.rawValue) ? Image(systemName: "circle.fill")
                                    .foregroundColor(Color("color-prime")).imageScale(.medium) : Image(systemName:"circle")
                                    .foregroundColor(.primary).imageScale(.medium)
                            }
                            Text(_sport.wrappedValue.rawValue)
                                .font(.callout)
                            Spacer()
                        }.padding(.top)
                    }
                    
                    
                }
                .padding(.leading)
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { self.router.navigateBack() }) {
                    Image(systemName: "chevron.left")
                    
                }
                .clipShape(Circle())
            }
            
            ToolbarItem(placement: .topBarTrailing) {
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
                            self.router.navigateBack()
                        }
                    }
                }){
                    LoadingButton(text: "Search", width: 100, status: $status)
                        .frame(width: 100)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        MapOptions(availableSports: [SPORTS.soccer, SPORTS.basketball, SPORTS.golf], selectedSports: ["soccer", "basketball", "pickleball"])
            .environmentObject(EventRouter())
            .environmentObject(SessionStore())
            .navigationBarBackButtonHidden(false)
    }
}
