//
//  EventViewExt.swift
//  Olympsis
//
//  Created by Joel on 7/27/23.
//

import SwiftUI
import CoreLocation
import Charts
import _MapKit_SwiftUI

struct EventViewExt: View {
    
    @Binding var event: Event
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
        guard let stat = event.status else {
            return "unknown"
        }
        return stat
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
        ScrollView(showsIndicators: false) {
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
                    
                    Button(action:{ self.presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                    }.clipShape(Circle())
                    
                }.padding(.horizontal)
                    .frame(maxWidth: .infinity)
                
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
                    
                Text("Details")
                    .font(.title2)
                    .bold()
                    .padding(.leading)
                Text(eventBody)
                    .padding(.horizontal)
                
                
                // middle view
                EventMiddleView(event: $event)
                
                // action buttons
                EventActionButtons(event: $event)
                    .padding(.top)
                
                // rsvp chart
                EventRSVPChart(event: $event)
                
                // participants view
                VStack {
                    ScrollView(.horizontal ,showsIndicators: false){
                        HStack {
                            ForEach(event.participants ?? [Participant](), id:\.id) { p in
                                ParticipantView(participant: p)
                            }
                        }.padding(.horizontal)
                    }
                }
                
                // field/club view
                EventExtDetail(data: event.data)
                    .padding(.top)
                
            }.padding(.top)
        }
    }
}


// MARK: - MIDDLE VIEW
struct EventMiddleView: View {
    
    @Binding var event: Event
    @State private var timeDifference = 0
    
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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.primary, lineWidth: 1)
                .padding(.horizontal)
                .frame(height: 70)
            HStack (alignment: .center){
                VStack(alignment: .center){
                    if event.status == EVENT_STATUS.in_progress.rawValue {
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.red)
                            Text("Live")
                                .bold()
                            .foregroundColor(.red)
                            
                        }
                        Text("\(timeDifference) mins")
                            .foregroundColor(.primary)
                            .bold()
                            .onAppear {
                                timeDifference = getTimeDifference()
                                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { t in
                                    timeDifference = getTimeDifference()
                                }
                            }
                    } else if event.status == EVENT_STATUS.pending.rawValue{
                        VStack {
                            Text("Pending")
                                .foregroundColor(Color("color-prime"))
                            Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.green)
                                .bold()
                        }
                    } else if event.status == EVENT_STATUS.completed.rawValue {
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
                    }
                }.padding(.leading)
                    .padding(.all, 7)
                
                Spacer()

                VStack {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text("\(potentialParticipants)/\(maxParticipants)")
                    }
                        .opacity(event.status == EVENT_STATUS.completed.rawValue ? 0 : 1)
                        .disabled(event.status == EVENT_STATUS.completed.rawValue)
                }
                
                Spacer()
                
                VStack(alignment: .center){
                    switch(event.level){
                    case 1:
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                        .foregroundColor(Color("tertiary-color"))
                    case 2:
                        HStack {
                            Circle()
                                .frame(width: 10)
                                .imageScale(.small)
                            .foregroundColor(Color("tertiary-color"))
                            Circle()
                                .frame(width: 10)
                                .imageScale(.small)
                            .foregroundColor(Color("tertiary-color"))
                        }
                    case 3:
                        HStack {
                            Circle()
                                .frame(width: 10)
                                .imageScale(.small)
                            .foregroundColor(Color("tertiary-color"))
                            Circle()
                                .frame(width: 10)
                                .imageScale(.small)
                            .foregroundColor(Color("tertiary-color"))
                            Circle()
                                .frame(width: 10)
                                .imageScale(.small)
                            .foregroundColor(Color("tertiary-color"))
                        }
                    default:
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                            .foregroundColor(Color("tertiary-color"))
                    }
                    
                    switch event.level {
                    case 1:
                        Text("Amateur")
                    case 2:
                        Text("Intermediate")
                    case 3:
                        Text("Expert")
                    default:
                        Text("Amateur")
                    }
                }.padding(.trailing)
                    .padding(.all, 7)
                    
            }.frame(maxWidth: .infinity)
                .padding(.horizontal)
        }
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
    
    private var estimatedTimeToField: String {
        guard let location = session.locationManager.location else {
            return "10 min"
        }
        
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let targetLocation = CLLocation(latitude: fieldLocation[1], longitude: fieldLocation[0])
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
                        Text(estimatedTimeToField)
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
                    Button(action: { Task{  await rsvp(status: "no") } }) {
                        Text("No")
                    }
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
    }
}

// MARK: - RSVP CHART
struct EventRSVPChart: View {
    @Binding var event: Event
    @EnvironmentObject private var session: SessionStore
    
    var yesCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let yesNum = participants.filter { p in
            return p.status == "yes"
        }
        return yesNum.count
    }
    
    var maybeCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let maybeNum = participants.filter { p in
            return p.status == "maybe"
        }
        return maybeNum.count
    }
    
    var noCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        let noNum = participants.filter { p in
            return p.status == "no"
        }
        return noNum.count
    }
    
    var body: some View {
        if event.participants != nil {
            Chart {
                BarMark(
                    x: .value("Responses", "yes"),
                    y: .value("Total Count", yesCount)
                ).foregroundStyle(Color("color-prime"))
                BarMark(
                    x: .value("Responses", "Maybe"),
                    y: .value("Total Count", maybeCount)
                ).foregroundStyle(Color("color-secnd"))
                BarMark(
                    x: .value("Responses", "No"),
                    y: .value("Total Count", noCount)
                ).foregroundStyle(Color("color-tert"))
            }.padding(.horizontal)
                .padding(.top)
        }
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

struct EventViewExt_Previews: PreviewProvider {
    static var previews: some View {
        EventViewExt(event: .constant(EVENTS[0])).environmentObject(SessionStore())
    }
}
