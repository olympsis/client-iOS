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
    /// The venue's owning organization, resolved from `venue.ownerID` when the
    /// view appears. Used to determine public/private status; `nil` until the
    /// (cached) fetch completes.
    @State private var ownerOrg: Organization?

    @Environment(\.openURL) private var openURL
    @Environment(SessionStore.self) private var session

    var joinGroupTip = JoinGroupTip()

    /// Whether this venue should be presented as public.
    ///
    /// Once the owner organization is resolved, verified organizations
    /// (government / official bodies) are treated as public and everyone else
    /// as private. Until the org loads — or when the venue has no owner — we
    /// fall back to the venue's own legacy heuristic.
    private var venueIsPublic: Bool {
        if let org = ownerOrg {
            return org.isVerified
        }
        return venue.isPublic()
    }

    /// Display name for the owning entity, preferring the resolved org's name
    /// and falling back to any legacy embedded ownership name.
    private var ownerName: String {
        ownerOrg?.name ?? venue.owner.name
    }

    /// Resolves the venue's owner organization (using the shared org cache so
    /// repeat opens of venues with the same owner don't hit the network).
    private func loadOwnerOrg() async {
        guard !venue.ownerID.isEmpty else { return }
        ownerOrg = await session.orgService.getCachedOrganization(id: venue.ownerID)
    }

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
                // When a booking URL exists the Schedule button becomes the
                // "primary" (filled) button, so Directions steps down to the
                // secondary style; otherwise Directions itself is primary.
                FlatButton(
                    title: estimatedTimeToField,
                    systemImage: "car.fill",
                    iconSize: CGSize(width: 20, height: 15),
                    background: bookingURL != nil ? Color.Background.secondary : Color.Foreground.default,
                    foreground: bookingURL != nil ? Color.Foreground.default : Color.Background.primary,
                    action: { leadToMaps() }
                )

                // MARK: - Visibility/Booking
                if let url = bookingURL {
                    FlatButton(
                        title: "Schedule",
                        systemImage: "calendar.badge.clock",
                        iconSize: CGSize(width: 20, height: 17),
                        background: Color.Foreground.default,
                        foreground: Color.Background.primary,
                        action: { openURL(url) }
                    )
                } else {
                    // No action: this pill toggles a popover via its own gesture
                    // rather than acting as a button.
                    FlatButton(
                        title: venueIsPublic ? "Public" : "Private",
                        systemImage: venueIsPublic ? "globe" : "lock.fill",
                        iconSize: venueIsPublic ? CGSize(width: 20, height: 20) : CGSize(width: 15, height: 20)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        showVisibility.toggle()
                    }
                    .popover(isPresented: $showVisibility, attachmentAnchor: .point(.bottom), arrowEdge: .top, content: {
                        VStack {
                            if venueIsPublic {
                                Text("Public")
                                    .fontWeight(.bold)
                                Text("This venue is owned by your state/local government.")
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Private")
                                    .fontWeight(.bold)
                                Text("This venue is privately owned by \(ownerName)")
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
                FlatButton(
                    title: "Event",
                    systemImage: "plus",
                    iconSize: CGSize(width: 15, height: 15),
                    foreground: canCreateEvent == false ? .gray : Color.Foreground.default,
                    action: { self.showNewEvent.toggle() }
                )
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
                    FlatButton(
                        title: "More",
                        systemImage: "ellipsis",
                        iconSize: CGSize(width: 20, height: 5)
                    )
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
            await loadOwnerOrg()
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
        let resp = await session.eventService.fetchEventsByVenueID(venue.id)
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
