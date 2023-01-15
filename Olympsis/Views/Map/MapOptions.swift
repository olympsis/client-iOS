//
//  MapOptions.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import SwiftUI

struct MapOptions: View {
    
    @AppStorage("storedRadius") private var storedRadius: Double?
    
    @State var availableSports:[String]
    @State private var radius: Double = 5.0
    @State private var selectedSports: [String] = [String]()
    
    @State private var status: LOADING_STATE = .pending
    
    @StateObject private var eventObserver = EventObserver()
    @StateObject private var fieldObserver = FieldObserver()
    
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func updateSports(sport:String){
        selectedSports.contains(where: {$0 == sport}) ? selectedSports.removeAll(where: {$0 == sport}) : selectedSports.append(sport)
    }
    
    func isSelected(sport:String) -> Bool {
        return selectedSports.contains(where: {$0 == sport})
    }
    
    func NewSearch() async {
        await MainActor.run {
            session.events = [Event]()
        }
        if let loc = session.locationManager.location {
            // fetch nearby fields
            await fieldObserver.fetchFields(longitude: loc.longitude, latitude: loc.latitude, radius: milesToMeters(radius: radius))
            await MainActor.run {
                session.fields = fieldObserver.fields
            }
            for sport in selectedSports {
                // fetch nearby events
                let res = await eventObserver.fetchEvents(longitude: loc.longitude, latitude: loc.latitude, radius: milesToMeters(radius: radius), sport: sport)
                if let e = res {
                    await MainActor.run {
                        session.events += e
                    }
                }
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Search Radius:")
                    .bold()
                HStack {
                    Slider(value: $radius, in: 5...500, step: 5)
                        .tint(Color("primary-color"))
                    Text("\(Int(radius)) miles")
                        .padding(.trailing)
                        .onChange(of: radius) { newValue in
                            storedRadius = newValue
                        }
                }
                Text("Sports:")
                    .bold()
                ForEach($availableSports, id: \.self){ _sport in
                    HStack {
                        Button(action: {updateSports(sport: _sport.wrappedValue)}){
                            isSelected(sport: _sport.wrappedValue) ? Image(systemName: "circle.fill")
                                .foregroundColor(Color("primary-color")).imageScale(.medium) : Image(systemName:"circle")
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
                            self.status = .loading
                            await NewSearch()
                            self.status = .success
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                        
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 40)
                                .foregroundColor(Color("primary-color"))
                            LoadingButton(text: "Search", width: 100, status: $status)
                        }
                    }.padding(.trailing)
                }.padding(.top)
            }.padding(.leading)
            .padding(.top, 20)
            .task {
                if let r = storedRadius {
                    self.radius = r
                }
                selectedSports = availableSports
            }
        }
    }
}

struct MapOptions_Previews: PreviewProvider {
    static var previews: some View {
        MapOptions(availableSports: ["Soccer", "Basketball", "Pickleball"])
    }
}
