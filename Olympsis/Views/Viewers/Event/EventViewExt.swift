//
//  EventViewExt.swift
//  Olympsis
//
//  Created by Joel on 7/27/23.
//

import MapKit
import SwiftUI
import CoreLocation


struct EventViewExt: View {
    
    @Binding var event: Event
    @State private var showParticipants: Bool = false
    @State private var status: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    var eventTitle: String {
        guard let title = event.title else {
            return "Error"
        }
        return title
    }
    
    var eventImage: String {
        guard let img = event.imageURL else {
            return ""
        }
        return  img
    }
    
    var eventBody: String {
        guard let body = event.body else {
            return ""
        }
        return body
    }
    
    var eventStatus: String {
        guard event.actualStartTime != nil else {
            return "pending"
        }
        
        guard event.stopTime != nil else {
            return "in-progress"
        }
        return "ended"
    }
    
    var fieldName: String {
        guard let data = event.data,
              let field = data.field else {
            return "No Field"
        }
        return field.name
    }
    
    var fieldLocality: String {
        guard let data = event.data,
              let field = data.field else {
            return "No Field"
        }
        
        return field.city + ", " + field.state
    }
    
    func reloadEvent() async {
        guard let id = event.id,
              let resp = await session.eventObserver.fetchEvent(id: id) else {
            handleFailure()
            return
        }
        
        event = resp
        handleSuccess()
    }
    
    func handleSuccess() {
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(eventTitle)
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer()
                
                Button(action: { Task { await reloadEvent() }}) {
                    switch status {
                    case .pending:
                        withAnimation {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.bold)
                        }
                    case .loading:
                        withAnimation {
                            ProgressView()
                        }
                    case .success:
                        withAnimation {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.bold)
                        }
                    case .failure:
                        withAnimation {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .imageScale(.medium)
                        }
                    }
                }.clipShape(Circle())
                    .frame(width: 25, height: 20)
                
                Button(action:{ self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }.clipShape(Circle())
                    .frame(width: 25, height: 20)

            }.padding(.horizontal)
                .padding(.top)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(fieldName)
                            .font(.title2)
                        Text(fieldLocality)
                    }.padding(.horizontal)
                        .padding(.top, 3)
                    
                    Image(eventImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // details/body
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Details")
                                .font(.title2)
                                .bold()
                            
                            Rectangle()
                                .frame(height: 1)
                            Text(event.dayToString())
                                .font(.callout)
                        }
                        Text(eventBody)
                    }.padding(.all)
                    
                    // MARK: - Middle View
                    EventMiddleView(event: $event)
                    
                    // MARK: - Action Buttons
                    EventActionButtons(event: $event)
                    
                    // MARK: - Participants View
                    EventParticipantsView(event: $event, showParticipants: $showParticipants)
                    
                    // MARK: - Field/Club Detail
                    EventExtDetail(data: event.data)
                }
            }
        }.sheet(isPresented: $showParticipants, content: {
            EventParticipantsViewExt(event: $event)
        })
    }
}


// MARK: - MIDDLE VIEW
struct EventMiddleView: View {
    
    @Binding var event: Event
    @State private var timeDifference: String = ""
    
    var startTime: Int64 {
        guard let time = event.startTime else {
            return 0
        }
        return time
    }
    
    var potentialParticipants: Int {
        guard let partcipants = event.participants else {
            return 0
        }
        let filtered = partcipants.filter({ $0.status == "yes" || $0.status == "maybe" })
        return filtered.count
    }
    
    var maxParticipants: Int {
        guard let max = event.maxParticipants else {
            return 0
        }
        return max
    }
    
    func getTimeDifference() -> Int {
        guard let startTime = event.actualStartTime else {
            return 2
        }
        let startDate = Date(timeIntervalSince1970: TimeInterval(startTime))
        let time = Calendar.current.dateComponents([.minute], from: startDate, to: Date.now)
        if let min = time.minute {
            return min
        }
        return 1
    }
    
    var eventLevel: Int {
        guard let level = event.level else {
            return 0
        }
        return level
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .padding(.horizontal)
                .frame(height: 70)
                .foregroundStyle(Color("background"))
            HStack (alignment: .center) {
                VStack(alignment: .center){
                    if event.stopTime != nil {
                        VStack {
                            Text("Ended")
                                .foregroundColor(.gray)
                                .bold()
                            if let sT = event.stopTime {
                                Text(Date(timeIntervalSince1970: TimeInterval(sT)).formatted(.dateTime.hour().minute()))
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                        }
                    } else if event.actualStartTime != nil {
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.red)
                            Text("Live")
                                .bold()
                                .foregroundColor(.red)
                        }
                        Text("\(timeDifference)")
                            .foregroundColor(.primary)
                            .bold()
                            .onAppear {
                                timeDifference = event.timeDifferenceToString()
                                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { t in
                                    timeDifference = event.timeDifferenceToString()
                                }
                            }
                    } else {
                        VStack {
                            Text("Pending")
                                .foregroundColor(Color("color-prime"))
                            Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.green)
                                .bold()
                        }
                    }
                }.padding(.leading)
                    .padding(.all, 7)
                
                Spacer()
                
                VStack {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text("\(potentialParticipants)/\(maxParticipants)")
                    }
                    .disabled(event.stopTime != nil)
                }
                
                Spacer()
                
                EventLevelView(level: eventLevel)
                
            }.padding(.horizontal)
        }.frame(maxWidth: .infinity)
            .padding(.vertical, 5)
    }
}

// MARK: - ACTION BUTTONS
struct EventActionButtons: View {
    
    @Binding var event: Event
    @State private var showMenu: Bool = false
    @State private var state: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    
    private var fieldLocation: [Double] {
        guard let data = event.data,
              let field = data.field else {
            return [0, 0]
        }
        return field.location.coordinates
    }
    
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
    
    private var hasRSVP: Bool {
        guard let user = session.user,
              let uuid = user.uuid,
              let participants = event.participants else {
            return false
        }
        return participants.first(where: { $0.uuid == uuid }) != nil
    }
    
    func rsvp(status: String) async {
        state = .loading
        guard let user = session.user,
              let uuid = user.uuid else {
            handleFailure()
            return
        }
        
        let participant = Participant(id: nil, uuid: uuid, data: nil, status: status, createdAt: nil)
        let resp = await session.eventObserver.addParticipant(id: event.id!, participant)
        
        guard resp == true,
              let id = event.id,
              let update = await session.eventObserver.fetchEvent(id: id) else {
            handleFailure()
            return
        }
        event = update
        handleSuccess()
    }
    
    func cancel() async {
        state = .loading
        guard let id = event.id,
            let user = session.user,
              let uuid = user.uuid,
              let participants = event.participants,
            let participantID = participants.first(where: { $0.uuid == uuid })?.id else {
            handleFailure()
            return
        }
        
        let resp = await session.eventObserver.removeParticipant(id: id, pid: participantID)
        guard resp == true,
            let id = event.id,
            let update = await session.eventObserver.fetchEvent(id: id) else {
            handleFailure()
            return
        }
        event = update
        handleSuccess()
    }
    
    func handleSuccess() {
        state = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    func handleFailure() {
        state = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }
    
    private func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(fieldLocation[1]),\(fieldLocation[0])")! as URL)
    }
    
    var body: some View {
        HStack {
            Button(action:{ leadToMaps() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("color-prime"))
                    
                    VStack {
                        VStack {
                            Image(systemName: "car.fill")
                                .resizable()
                                .frame(width: 25, height: 20)
                            .imageScale(.large)
                        }.frame(height: 25)
                        Text(event.estimatedTimeToField(session.locationManager.location))
                    }.foregroundColor(.white)
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(maxWidth: .infinity, idealHeight: 80)
                    .foregroundColor(Color("color-prime"))
                VStack {
                    if event.visibility == "private" {
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
            if !hasRSVP {
                Menu {
                    Button(action: { Task{  await rsvp(status: "maybe") } }) {
                        Text("Maybe")
                    }
                    Button(action:{ Task { await rsvp(status: "yes") } }){
                        Text("I'm In")
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 80)
                            .foregroundColor(Color("color-prime"))
                        VStack {
                            if state == .loading {
                                ProgressView()
                                    .frame(width: 30)
                            } else {
                                VStack {
                                    Image(systemName: "envelope.fill")
                                        .resizable()
                                        .frame(width: 30, height: 20)
                                }.frame(height: 25)
                                Text("RSVP")
                            }
                        }
                    }.foregroundColor(.white)
                }.disabled(state == .loading ? true : false)
                    .disabled(event.stopTime != nil ? true : false)
            } else {
                Button(action: { Task { await cancel() }}) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 80)
                            .foregroundColor(Color("color-prime"))
                        VStack {
                            if state == .loading {
                                ProgressView()
                                    .frame(width: 30)
                            } else {
                                VStack {
                                    Image(systemName: "envelope.open")
                                        .resizable()
                                        .frame(width: 30, height: 25)
                                }.frame(height: 25)
                                Text("Cancel")
                            }
                        }
                    }.foregroundColor(.white)
                }
            }
            
            Button(action:{ self.showMenu.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
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
            }.sheet(isPresented: $showMenu) {
                EventMenu(event: $event)
                    .presentationDetents([.height(200)])
            }
            
        }.padding(.horizontal)
            .padding(.top)
    }
}

// MARK: - FIELD/CLUB
struct EventExtDetail: View {
    @State var data: EventData?
    @EnvironmentObject private var session: SessionStore
    
    var isMember: Bool {
        guard let user = session.user,
              let clubs = user.clubs,
              clubs.count > 0,
              let club = data?.club,
              let id = club.id else {
            return false
        }
        return clubs.first(where: { $0 == id }) != nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let f = data?.field {
                VStack(alignment: .leading){
                    VStack(alignment: .leading){
                        Text(f.name)
                            .font(.title)
                            .bold()
                        Text(f.description)
                    }
                    VStack {
                        Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: f.location.coordinates[1], longitude: f.location.coordinates[0]), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), interactionModes: .zoom, showsUserLocation: false, annotationItems: [f], annotationContent: { field in
                            MapMarker(coordinate: CLLocationCoordinate2D(latitude: field.location.coordinates[1], longitude: field.location.coordinates[0]), tint: Color("color-prime"))
                        }).frame(height: 270)
                            .cornerRadius(10)
                    }
                }
            }
            
            if let c = data?.club {
                VStack(alignment: .leading){
                    Text("Host")
                        .font(.title)
                        .foregroundColor(.primary)
                        .bold()

                    Text(c.name ?? "")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    AsyncImage(url: URL(string:  GenerateImageURL(c.imageURL ?? ""))){ phase in
                        if let image = phase.image {
                            ZStack(alignment: .bottomTrailing) {
                                image
                                        .resizable()
                                        .frame(height: 300, alignment: .center)
                                        .aspectRatio(contentMode: .fit)
                                        .clipped()
                                    .cornerRadius(10)
                                if !isMember {
                                    Menu{
                                        Button(action:{}){
                                            Label("View Details", systemImage: "ellipsis")
                                        }
                                        Button(action:{}){
                                            Label("Report an Issue", systemImage: "exclamationmark.shield")
                                        }
                                    }label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
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
                                    }.frame(width: 100, height: 80)
                                        .padding(.all, 10)
                                }
                            }
                            
                            } else if phase.error != nil {
                                ZStack {
                                    Color(.gray) // Indicates an error.
                                        .cornerRadius(10)
                                    .frame(height: 300, alignment: .center)
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(.white)
                                }
                            } else {
                                ZStack {
                                    Color(.gray) // Indicates an error.
                                        .opacity(0.8)
                                        .cornerRadius(10)
                                    .frame(height: 300, alignment: .center)
                                    ProgressView()
                                }
                            }
                    }
                    
                    Text(c.description ?? "")
                        .padding(.bottom)
                }
            }
        }.padding(.horizontal)
            .frame(maxWidth: .infinity)
    }
}

struct EventLevelView: View {
    @State var level: Int
    var body: some View {
        VStack {
            if level == 1 {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text("Beginner")
                }
            } else if level == 2 {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text("Amateur")
                }
            } else if level == 3 {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text("Expert")
                }
            } else {
                VStack(alignment: .center){
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("color-tert"))
                    }
                    
                    Text("Any")
                }
            }
        }.padding(.trailing)
            .padding(.all, 7)
    }
}



struct EventViewExt_Previews: PreviewProvider {
    static var previews: some View {
        EventViewExt(event: .constant(EVENTS[0])).environmentObject(SessionStore())
    }
}
