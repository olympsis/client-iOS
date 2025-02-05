//
//  FieldViewExt.swift
//  Olympsis
//
//  Created by Joel on 7/26/23.
//

import TipKit
import SwiftUI
import Kingfisher
import CoreLocation

struct VenueView: View {
    
    @State var venue: Venue
    @State private var status: LOADING_STATE = .loading
    @Environment(SessionStore.self) private var session
    @Environment(\.presentationMode) private var presentationMode
    
    var fieldLocation: String {
        return venue.city + ", " + venue.state
    }
    
    var hasClubs: Bool {
        guard let user = session.user,
              let clubs = user.clubs,
              !clubs.isEmpty else {
            return false
        }
        return true
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                // MARK: - Name
                VStack(alignment: .leading) {
                    HStack {
                        Text(venue.name)
                            .font(.title)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .bold()
                        
                        Spacer()
                        
                        Button(action:{ self.presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                        }
                        .clipShape(Circle())
                    }.padding(.horizontal)
                    
                    Text(fieldLocation)
                        .padding(.leading)
                }
                
                // MARK: - Images
                VenueImages(venue: venue)
                
                // MARK: - Description
                Text(String(localized: "About this Venue", table: "General"))
                    .bold()
                    .font(.title2)
                    .padding(.leading)
                    .padding(.top)
                
                Text(venue.description)
                    .font(.callout)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // MARK: - Action Buttons
                VenueActionButtons(venue: venue)
                
                //MARK: - Events View
                VenueEventsView(venue: $venue)
                
            }       
        }.padding(.top)
    }
}


struct VenueImages: View {
    
    @State var venue: Venue
    @State private var showFullImage: Bool = false
    
    var images: [URL] {
        var arr = [URL]()
        venue.images.forEach { img in
            if let url = generateImageURL(img) {
                arr.append(url)
            }
        }
        return arr
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(images, id: \.self) { i in
                    KFImage(i)
                        .placeholder({
                            ImageLoadingView()
                        })
                        .resizable()
                        .setProcessor(venueImageProcessor(size: CGSize(width: 220*2, height: 300*2)))
                        .frame(width: 220, height: 300, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.leading)
                        .onTapGesture {
                            self.showFullImage.toggle()
                        }
                        .fullScreenCover(isPresented: $showFullImage, content: {
                            FullImageViewer(imageURL: i)
                        })
                }
            }
        }
    }
}

struct VenueActionButtons: View {
    
    @State var venue: Venue
    @State private var showReport: Bool = false
    @State private var showNewEvent: Bool = false
    @State private var showVisibility: Bool = false
    @Environment(SessionStore.self) private var session
    
    var joinGroupTip = JoinGroupTip()
    
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
        let targetLocation = CLLocation(latitude: venue.location.coordinates[1], longitude: venue.location.coordinates[0])
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
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])")! as URL)
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
                    .foregroundColor(Color("background"))
                VStack {
                    if venue.isPublic() {
                        VStack {
                            Image(systemName: "globe")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text("Public")
                        }.foregroundColor(Color("foreground"))
                    } else {
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .frame(width: 20, height: 25)
                            Text("Private")
                        }.foregroundColor(Color("foreground"))
                    }
                }
            }.onTapGesture {
                showVisibility.toggle()
            }
            .popover(isPresented: $showVisibility, attachmentAnchor: .point(.top), arrowEdge: .top, content: {
                VStack {
                    if venue.isPublic() {
                        Text("Public")
                            .fontWeight(.bold)
                        Text("This venue is owned by your state/local government.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Private")
                            .fontWeight(.bold)
                        Text("This venue is privately owned by \(venue.owner.name)")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                }.presentationCompactAdaptation(.popover)
                    .presentationBackground(content: {
                        Color("background")
                    })
                    .frame(width: 200)
                    .padding(.vertical)
            })
            
            Button(action: { self.showNewEvent.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("background"))
                    VStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("Event")
                    }.foregroundStyle(canCreateEvent == false ? .gray : Color("foreground"))
                }
            }.disabled(canCreateEvent == false ? true : false)
                .popoverTip(joinGroupTip)
            .sheet(isPresented: $showNewEvent) {
                NewEvent(manager: NewEventManager(venues: [venue]))
            }
            
            Menu{
                Button(action:{ showReport.toggle() }){
                    Label("Report an Issue", systemImage: "exclamationmark.shield")
                }
            }label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 80)
                        .foregroundColor(Color("background"))
                    VStack {
                        VStack {
                            Image(systemName: "ellipsis")
                                .resizable()
                            .frame(width: 25, height: 5)
                        }.frame(height: 25)
                        Text("More")
                    }.foregroundColor(Color("foreground"))
                }
            }.fullScreenCover(isPresented: $showReport, content: {
                FieldReportView(field: venue)
            })
            
        }.padding(.horizontal)
            .task {
                try? Tips.configure([
                    .displayFrequency(.immediate),
                    .datastoreLocation(.applicationDefault)
                ])
            }
    }
}

struct VenueEventsView: View {
    
    @Binding var venue: Venue
    @State private var status: LOADING_STATE = .pending
    @Environment(SessionStore.self) private var session
    
    var fieldEvents: [Event] {
        return session.events.filter({ $0.venues?.contains(where: { $0.id == venue.id }) ?? false })
    }
    
    func reloadEvents() async {
        status = .loading
        let resp = await session.eventObserver.fetchEventsByFieldID(venue.id)
        guard let events = resp else {
            handleReloadFailure()
            return
        }
        
        // remove existing events and we will append the newly requested events
        session.events.removeAll(where: { $0.venues?.contains(where: { $0.id == venue.id }) ?? false })
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
                            EventListItem(event: event)
                        }
                    }
                }
            }
        }.padding(.all)
    }
}

struct FieldViewExt_Previews: PreviewProvider {
    static var previews: some View {
        VenueView(venue: FIELDS[0]).environment(SessionStore())
    }
}
