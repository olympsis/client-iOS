//
//  FieldViewExt.swift
//  Olympsis
//
//  Created by Joel on 7/26/23.
//

import SwiftUI
import CoreLocation

struct FieldViewExt: View {
    
    @State var field: Field
    @State private var status: LOADING_STATE = .loading
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    var fieldLocation: String {
        return field.city + ", " + field.state
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                // MARK: - Name
                VStack(alignment: .leading) {
                    HStack {
                        Text(field.name)
                            .font(.title)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .bold()
                        
                        Spacer()
                        
                        Button(action:{ self.presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(Color("color-prime"))
                        }.clipShape(Circle())
                    }.padding(.horizontal)
                    
                    Text(fieldLocation)
                        .padding(.leading)
                }
                
                // MARK: - Images
                FieldImages(field: field)
                
                // MARK: - Description
                Text("About this Place")
                    .bold()
                    .font(.title2)
                    .padding(.leading)
                    .padding(.top)
                
                Text(field.description)
                    .font(.callout)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // MARK: - Action Buttons
                FieldActionButtons(field: field)
                
                //MARK: - Events View
                FieldEventsView(field: $field)
                
            }       
        }.padding(.top)
    }
}


struct FieldImages: View {
    
    @State var field: Field
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(field.images, id: \.self) { i in
                    AsyncImage(url: URL(string:  GenerateImageURL(i))){ phase in
                        if let image = phase.image {
                                image // Displays the loaded image.
                                    .resizable()
                                    .frame(width: 220, height: 300, alignment: .center)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                            
                            } else if phase.error != nil {
                                ZStack {
                                    Color(.gray) // Indicates an error.
                                    .frame(width: 220, height: 300, alignment: .center)
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(.white)
                                }
                            } else {
                                ZStack {
                                    Color(.gray) // Indicates an error.
                                        .opacity(0.8)
                                    .frame(width: 220, height: 300, alignment: .center)
                                    ProgressView()
                                }
                            }
                    }.padding(.leading)
                }
            }
        }
    }
}

struct FieldActionButtons: View {
    
    @State var field: Field
    @State private var showNewEvent = false
    @EnvironmentObject private var session: SessionStore
    
    private var canCreateEvent: Bool {
        guard let user = session.user,
              let clubs = user.clubs,
              user.sports != nil,       // at least have a sport
              clubs.count > 0,          // at least have a club
              session.clubs.count > 0 else { // data for club has been fetched
            return false
        }
        return true
    }
    
    private var estimatedTimeToField: String {
        guard let location = session.locationManager.location else {
            return "10 min"
        }
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let targetLocation = CLLocation(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0])
        let distance = currentLocation.distance(from: targetLocation)
        let speed: CLLocationSpeed = 500 // Assuming a speed of 500 meters/minute
        let timeDifference = distance / speed
        
        if timeDifference < 0 {
            return "1 min"
        }
        
        let timeInMinutes = Int(timeDifference)
        
        if timeInMinutes < 60 {
            return "\(timeInMinutes) min"
        } else {
            let hours = timeInMinutes / 60
            let minutes = timeInMinutes % 60
            let formattedTime = String(format: "%d:%02d min", hours, minutes)
            return formattedTime
        }
    }
    
    private func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[1]),\(field.location.coordinates[0])")! as URL)
    }
    
    var body: some View {
        HStack {
            Button(action:{ leadToMaps() }) {
                ZStack {
                    Rectangle()
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("color-prime"))
                    
                    VStack {
                        VStack {
                            Image(systemName: "car.fill")
                                .resizable()
                                .frame(width: 25, height: 20)
                            .imageScale(.large)
                        }.frame(height: 25)
                        Text(estimatedTimeToField)
                    }.foregroundColor(.white)
                }
            }
            
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, idealHeight: 80)
                    .foregroundColor(Color("color-prime"))
                VStack {
                    if field.owner.type == "private" {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .frame(width: 20, height: 25)
                            Text("Private")
                        }.foregroundColor(.white)
                    } else {
                        VStack {
                            Image(systemName: "globe")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("Public")
                        }.foregroundColor(.white)
                    }
                }
            }
            
            Button(action: { self.showNewEvent.toggle() }) {
                ZStack {
                    Rectangle()
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("color-prime"))
                    VStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("Event")
                    }.foregroundColor(canCreateEvent == false ? .gray : .white)
                }
            }.disabled(canCreateEvent == false ? true : false)
            .sheet(isPresented: $showNewEvent) {
                NewEvent()
            }
            
            Menu{
                Button(action:{}){
                    Label("Report an Issue", systemImage: "exclamationmark.shield")
                }
            }label: {
                ZStack {
                    Rectangle()
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("color-prime"))
                    VStack {
                        VStack {
                            Image(systemName: "ellipsis")
                                .resizable()
                            .frame(width: 25, height: 5)
                        }.frame(height: 25)
                        Text("More")
                    }.foregroundColor(.white)
                }
            }
            
        }.padding(.horizontal)
    }
}

struct FieldEventsView: View {
    
    @Binding var field: Field
    @State private var status: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    var fieldEvents: [Event] {
        return session.events.filter({ $0.fieldID == field.id })
    }
    
    func reloadEvents() async {
        status = .loading
        let resp = await session.eventObserver.fetchEventsByFieldID(field.id)
        guard let events = resp else {
            handleReloadFailure()
            return
        }
        
        // remove existing events and we will append the newly requested events
        session.events.removeAll(where: { $0.fieldID == field.id })
        session.events.append(contentsOf: events)
        handleReloadSuccess()
    }
    
    func handleReloadSuccess() {
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    func handleReloadFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    var body: some View {
        
        //MARK: - Events View
        VStack(alignment: .leading){
            HStack {
                Text("Events")
                    .font(.title3)
                    .bold()
                    .frame(height: 20)
                HStack {
                    Rectangle()
                        .frame(height: 1)
                    
                    Button(action: { Task { await reloadEvents() }}) {
                        switch status {
                        case .pending:
                            withAnimation {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.primary)
                            }
                        case .loading:
                            withAnimation {
                                ProgressView()
                            }
                        case .success:
                            withAnimation {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.primary)
                            }
                        case .failure:
                            withAnimation {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            if fieldEvents.isEmpty {
                VStack(alignment: .center){
                    Text("There are no events at this field. 🥹")
                        .padding(.all)
                }.frame(maxWidth: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    if status == .loading {
                        EventTemplateView()
                        EventTemplateView()
                        EventTemplateView()
                    } else if status == .failure {
                        Text("Failed to load events")
                            .foregroundColor(.red)
                            .padding(.top)
                    }else {
                        ForEach(fieldEvents) { event in
                            EventView(event: event)
                        }
                    }
                }
            }
        }.padding(.all)
    }
}

struct FieldViewExt_Previews: PreviewProvider {
    static var previews: some View {
        FieldViewExt(field: FIELDS[0]).environmentObject(SessionStore())
    }
}
