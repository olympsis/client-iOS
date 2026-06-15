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
    var isFullScreen: Bool = false
    @State private var status: LOADING_STATE = .loading
    @Environment(SessionStore.self) private var session
    @Environment(\.presentationMode) private var presentationMode
    
    private var fieldLocation: String {
        return venue.city + ", " + venue.state
    }
    
    private var hasClubs: Bool {
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
                if !isFullScreen {
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
                }
                
                // MARK: - Images
                VenueImages(venue: venue)
                
                // MARK: - Description
                Text(String(localized: "About this Location", table: "General"))
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
                
                // MARK: - Details
                VenueDetails(venue: venue)
                
                //MARK: - Events
                VenueEventsView(venue: $venue)
                
            }.navigationTitle(venue.name)
        }
        .padding(.top, isFullScreen ? 0 : 10)
        .background(Color.Background.primary)
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
    
    @Environment(\.openURL) private var openURL
    @Environment(SessionStore.self) private var session
    
    var joinGroupTip = JoinGroupTip()
    
    private var bookingURL: URL? {
        guard let string = venue.bookingURL,
              let url = URL(string: string) else {
            return nil
        }
        return url
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
    
    private var estimatedTimeToField: String {
        guard let location = LocationManager.shared.location else {
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
        VStack {
            if (venue.requiresBooking) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    
                    Text("This location may require an external reservation before you can host an event")
                        .font(.caption)
                }.padding(.bottom, 10)
            }
            
            HStack {
                
                // MARK: - Directions Button
                Button(action:{ leadToMaps() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 60)
                            .foregroundColor(bookingURL != nil ? Color.Background.secondary : Color.Foreground.default)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.border, lineWidth: 1)
                            }
                        
                        VStack(spacing: 6) {
                            VStack {
                                Image(systemName: "car.fill")
                                    .resizable()
                                    .frame(width: 20, height: 15)
                            }
                            
                            Text(estimatedTimeToField)
                                .font(.caption)
                                .fontWeight(.bold)
                        }.foregroundColor(bookingURL != nil ? Color.Foreground.default : Color.Background.primary)
                    }
                }.contentShape(RoundedRectangle(cornerRadius: 10))
                
                // MARK: - Visibility/Booking
                if let url = bookingURL {
                    Button(action: { openURL(url) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxWidth: .infinity, idealHeight: 60)
                                .foregroundStyle(Color.Foreground.default)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.border, lineWidth: 1)
                                }
                            
                            VStack {
                                Image(systemName: "calendar.badge.clock")
                                    .resizable()
                                    .frame(width: 20, height: 17)
                                Text("Schedule")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }.foregroundStyle(Color.Background.primary)
                        }
                    }.contentShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 60)
                            .foregroundColor(Color(Color.Background.secondary))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.border, lineWidth: 1)
                            }
                        
                        VStack {
                            if venue.isPublic() {
                                VStack {
                                    Image(systemName: "globe")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("Public")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }.foregroundColor(Color.Foreground.default)
                            } else {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .resizable()
                                        .frame(width: 15, height: 20)
                                    Text("Private")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }.foregroundColor(Color.Foreground.default)
                            }
                        }
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
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
                        }
                        .presentationCompactAdaptation(.popover)
                        .presentationBackground(content: {
                            Color(Color.Background.secondary)
                        })
                        .frame(width: 200)
                        .padding(.vertical)
                    })
                }
                
                // MARK: - New Event
                Button(action: { self.showNewEvent.toggle() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 60)
                            .foregroundColor(Color(Color.Background.secondary))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.border, lineWidth: 1)
                            }
                        
                        VStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 15, height: 15)
                            Text("Event")
                                .font(.caption)
                                .fontWeight(.bold)
                        }.foregroundStyle(canCreateEvent == false ? .gray : Color.Foreground.default)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .disabled(canCreateEvent == false ? true : false)
                .popoverTip(joinGroupTip)
                .fullScreenCover(isPresented: $showNewEvent) {
                    NewEvent(manager: NewEventManager(venues: [venue]))
                }
                
                // MARK: - More
                Menu{
                    Button(action:{ showReport.toggle() }){
                        Label("Report an Issue", systemImage: "exclamationmark.shield")
                    }
                }label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(maxWidth: .infinity, idealHeight: 60)
                            .foregroundColor(Color(Color.Background.secondary))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.border, lineWidth: 1)
                            }
                        VStack {
                            VStack {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .frame(width: 20, height: 5)
                            }.frame(height: 15)
                            Text("More")
                                .font(.caption)
                                .fontWeight(.bold)
                        }.foregroundColor(Color.Foreground.default)
                    }
                }.fullScreenCover(isPresented: $showReport, content: {
                    FieldReportView(field: venue)
                })
            }
        }
        .padding(.horizontal)
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
    @State private var selectedEvent: Event?
    @State private var showEventView: Bool = false
    @State private var status: LOADING_STATE = .pending
    @Environment(SessionStore.self) private var session
    
    var fieldEvents: [Event] {
        // Use the shared loose-match predicate so imported/scraped events that
        // overlap this venue by name (and lack our internal venueID) still show
        // up here — keeping this list in sync with the map's "has events" dot.
        return session.events.filter { venue.hosts($0) }
    }
    
    func reloadEvents() async {
        status = .loading
        let resp = await session.eventObserver.fetchEventsByFieldID(venue.id)
        guard let events = resp else {
            handleReloadFailure()
            return
        }
        
        events.forEach { session.events.insert($0) }
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
                    Text("There are no events at this location 🥹")
                        .padding(.all)
                    
                    Spacer(minLength: 100)
                    
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
                    } else {
                        ForEach(fieldEvents) { event in
                            EventListItem(event: event)
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                    }
                    
                    Spacer(minLength: 70)
                }
            }
        }
        .padding(.all)
        .fullScreenCover(item: $selectedEvent, content: { event in
            EventView(event: event, isFullScreen: true)
                .environment(event)
                .environment(session)
        })
    }
}

#Preview("Sheet") {
    VenueView(venue: VENUES[0])
        .environment(SessionStore())
}

#Preview("Full Screen") {
    NavigationStack {
        VenueView(venue: VENUES[0], isFullScreen: true)
            .environment(SessionStore())
    }
}
