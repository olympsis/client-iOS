//
//  EventDetailView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import MapKit
import SwiftUI

struct EventDetailView: View {
    
    @State var event:           Event
    @State var field:           Field
    @State private var club:    Club?
    
    @Binding var events: [Event]
    
    @State private var showMenu = false
    
    @StateObject private var clubObserver = ClubObserver()
    @StateObject private var eventObserver = EventObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[0]),\(field.location.coordinates[1])")! as URL)
    }
    
    func RSVP(status: String) async {
        if let user = session.user {
            let dao = ParticipantDao(_uuid: user.uuid, _status: status)
            let res = await eventObserver.addParticipant(id: event.id, dao: dao)
            if let r = res {
                let p = Participant(id: r.id, uuid: r.uuid, status: status, imageURL: user.imageURL ?? "", createdAt: r.createdAt)
                withAnimation(.spring()){
                    if event.participants != nil {
                        event.participants!.append(p)
                    } else {
                        event.participants = [p]
                    }
                }
            }
        }

    }
    
    func Cancel() async {
        if let user = session.user {
            if let pid = event.participants?.first(where: {$0.uuid == user.uuid}){
                let res = await eventObserver.removeParticipant(id: event.id, pid: pid.id)
                if res {
                    withAnimation(.easeOut) {
                        event.participants?.removeAll(where: {$0.uuid == user.uuid})
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack{
                
                    // MARK: - Action Buttons
                    HStack {
                        Button(action:{ self.presentationMode.wrappedValue.dismiss() }){
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }.padding(.leading, 25)
                        
                        Spacer()
                        
                        Button(action:{}){
                            Image(systemName: "heart")
                                .foregroundColor(.white)
                        }
                        
                        Button(action:{}){
                            Image(systemName: "bell")
                                .foregroundColor(.white)
                        }
                        
                        Button(action:{self.showMenu.toggle()}){
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                            
                        }.padding(.trailing)
                    }
                    
                    // MARK: - Event Info
                    HStack {
                        VStack(alignment: .leading){
                            Text(event.title)
                                .foregroundColor(.white)
                                .bold()
                                .font(.largeTitle)
                            HStack {
                                Text(field.city)
                                    .foregroundColor(.white)
                                    .font(.title)
                                Text(", \(field.state)")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            Text(field.name)
                                .foregroundColor(.white)
                                .font(.title3)
                            HStack {
                                Button(action:{self.leadToMaps()}) {
                                    Image(systemName: "location")
                                        .foregroundColor(.white)
                                    .imageScale(.large)
                                }
                                Text("Directions")
                                    .foregroundColor(.white)
                                
                                    
                            }.padding(.top)
                        }.padding(.leading, 20)
                        Spacer()
                    }.padding(.top)
                    
                    // MARK: - Middle View
                    EventDetailMiddleView(event: event)
                    
                    // MARK: - Event Body
                    HStack {
                        Text(event.body)
                            .padding(.top)
                            .padding(.leading, 25)
                            .font(.body)
                            .foregroundColor(.white)
                            .bold()
                        Spacer()
                    }
                    
                    if let part = event.participants{
                        if part.count > 0 {
                            ScrollView(.horizontal ,showsIndicators: false){
                                HStack {
                                    ForEach(part, id:\.id) { p in
                                        ParticipantView(participant: p)
                                    }
                                } .padding(.leading)
                            }
                        }
                    }
                    if let user = session.user {
                        if (event.participants?.first(where: {$0.uuid == user.uuid})) == nil {
                            HStack {
                                Button(action:{
                                    Task {
                                        await RSVP(status: "going")
                                    }
                                }){
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 100, height: 30)
                                            .foregroundColor(Color("primary-color"))
                                        Text("I'm going")
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                }.padding(.top, 20)
                                Button(action:{
                                    Task {
                                        await RSVP(status: "not sure")
                                    }
                                }){
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 100, height: 30)
                                            .foregroundColor(.gray)
                                        Text("Not sure")
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                }.padding(.top, 20)
                            }
                        } else {
                            Button(action:{
                                Task {
                                    await Cancel()
                                }
                            }){
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 100, height: 30)
                                        .foregroundColor(.red)
                                    Text("Cancel")
                                        .foregroundColor(.white)
                                        .bold()
                                }
                            }.padding(.top, 20)
                        }
                    }
                    
                   
                    
                    // MARK: - Map View
                    VStack(){
                        HStack (){
                            Text(field.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            .padding(.leading)
                            Spacer()
                        }
                        Text(field.notes)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                            .padding(.bottom)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 10)
                            
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: field.location.coordinates[0], longitude: field.location.coordinates[1]), span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0030))), interactionModes: .pan, showsUserLocation: false, annotationItems: [field], annotationContent: { field in
                            MapMarker(coordinate: CLLocationCoordinate2D(latitude: field.location.coordinates[0], longitude: field.location.coordinates[1]), tint: Color("primary-color"))
                        }).frame(width: SCREEN_WIDTH-20, height: 270)
                            .cornerRadius(10)
                    }.padding(.top, 50)
                    
                    // MARK: Host
                    VStack(alignment: .leading){
                        if let club = self.club {
                            Text("Host")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                                .padding(.top, 20)
                            
                            Spacer()
                            
                            Text(club.name)
                                .font(.title2)
                                .foregroundColor(.white)
                                .bold()

                            AsyncImage(url: URL(string: club.imageURL)){ phase in
                                if let image = phase.image {
                                        image // Displays the loaded image.
                                            .fixedSize()
                                            .frame(width: SCREEN_WIDTH-20, height: 250)
                                            .scaledToFit()
                                            .clipped()
                                            .cornerRadius(10)
                                    } else if phase.error != nil {
                                        Color.red // Indicates an error.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    } else {
                                        Color.gray // Acts as a placeholder.
                                            .clipShape(Circle())
                                            .opacity(0.3)
                                    }
                            }.frame(width: SCREEN_WIDTH-20, height: 250)
                            
                            Text(club.description)
                                .foregroundColor(.white)
                                .padding(.top, 5)
                                .padding(.bottom)
                        }
                        
                    }.frame(width: SCREEN_WIDTH-20)
                        
                    
                }.frame(width: SCREEN_WIDTH)
                    .toolbar(.hidden)
                    .background {
                        Image(event.imageURL)
                            .scaledToFill()
                            .opacity(0.8)
                            .blur(radius: 3, opaque: true)
                    }
            }.task {
                let _club = await clubObserver.getClub(id: event.clubId)
                if let c = _club {
                    self.club = c
                }
            }
            .sheet(isPresented: $showMenu) {
                EventMenu(event: event, events: $events)
                    .presentationDetents([.height(200)])
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(id: "", owner: Owner(uuid: "", username: "unnamed_user", imageURL: ""), clubId: "", fieldId: "", imageURL: "soccer-0", title: "Pick Up Soccer", body: "Just come out and play boys.", sport: "soccer", level: 3, status: "pending", startTime: 0, maxParticipants: 0, participants: [Participant(id: "", uuid: "", status: "going", imageURL: "https://storage.googleapis.com/olympsis-1/profile-img/dorrell-tibbs-GntSiIMHyVM-unsplash.jpg", createdAt: 0)])
        let field = Field(id: "", owner: "", name: "Richard Building Fields", notes: "Private field owned by BYU. Turf field with medium sized goals.", sports: [""], images: [""], location: GeoJSON(type: "", coordinates: [0.0, 0.0]), city: "Provo", state: "Utah", country: "United States of America", isPublic: false)
        EventDetailView(event: event, field: field, events: .constant([Event]())).environmentObject(SessionStore())
    }
}
