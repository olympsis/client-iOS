//
//  Home.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct Home: View {
    
    // status of loading event
    enum Status {
        case loading
        case failed
        case done
    }
    
    @State private var index = "0"
    @State private var fieldIndex = "0"
    @State private var hasLoaded = false // to make sure user location is updated once
    @State private var showDetail = false
    @State private var hasOpened = false
    @State private var status: Status = .loading

    @StateObject private var observer = FeedObserver()
    @StateObject private var eventObserver = EventObserver()
    @StateObject private var fieldObserver = FieldObserver()
    @StateObject private var locationManager = LocationManager()
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HStack {
                        VStack(alignment: .leading){
                            Text("Welcome back \(session.getFirstName())")
                                .font(.custom("Helvetica Neue", size: 25))
                                .fontWeight(.regular)
                            Text("ready to play?")
                                .font(.custom("Helvetica Neue", size: 20))
                                .fontWeight(.light)
                                .foregroundColor(.gray)
                        }.padding(.leading)
                            .padding(.top, 25)
                        Spacer()
                    }
                    Spacer()
                    
                    //MARK: - Announcements
                    HStack{
                        VStack(alignment: .leading){
                            Text("Announcements")
                                .font(.custom("Helvetica Neue", size: 17))
                                .bold()
                                .padding()
                            VStack {
                                TabView(selection: $index){
                                    ForEach(observer.announcements){ announcement in
                                        AnnouncementView(announcement: announcement).tag(announcement.id)
                                    }
                                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                    .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2, alignment: .center)
                                
                                // Page View Indicator
                                VStack{
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(observer.announcements, id: \.id) { index in
                                            Rectangle()
                                                .fill(index.id == self.index ? Color("primary-color") : Color("primary-color").opacity(0.5))
                                                .frame(width: 30, height: 5)
                                        }
                                    }.padding()
                                }
                            }.onChange(of: observer.announcements, perform: { newValue in
                                if !observer.announcements.isEmpty{
                                    self.index = observer.announcements[0].id
                                }
                            })
                        }
                    }
                    
                    //MARK: - Nearby Fields
                        HStack {
                            VStack(alignment: .leading){
                                HStack {
                                    Text("Nearby Fields")
                                        .font(.system(.headline))
                                    .padding()
                                    Spacer()
                                    // This will be added back in later
                                   /* Button(action:{}){
                                        Text("View All")
                                        Image(systemName: "chevron.down")
                                    }.padding()
                                        .foregroundColor(Color.primary)*/
                                }
                                
                                if fieldObserver.isLoading {
                                    FieldViewTemplate()
                                } else {
                                    if session.fields.isEmpty {
                                        VStack(alignment: .center){
                                            Text("😞 Sorry there are no fields in your area.")
                                        }.frame(width: SCREEN_WIDTH, height: 200)
                                    } else {
                                        ScrollView(.horizontal, showsIndicators: false){
                                            HStack{
                                                ForEach(session.fields, id: \.name){ field in
                                                    FieldView(field: field)
                                                }
                                            }
                                        }.frame(width: SCREEN_WIDTH, height: 365, alignment: .center)
                                    }
                                }
                            }
                        }.onReceive(locationManager.$location) { newLoc in
                            // we have to wait an undetermined amount of time to hear back from the gps to get location
                            // so i used on recieve and after that info is delivered we can start fetching for fields by location
                            if let location = newLoc {
                                guard hasLoaded == false else {
                                    return
                                }
                                Task {
                                    // fetch nearby fields
                                    await fieldObserver.fetchFields(longitude: location.longitude, latitude: location.latitude, radius: 10)
                                    session.fields = fieldObserver.fields
                                    
                                    // fetch nearby events
                                    await eventObserver.fetchEvents(longitude: location.longitude, latitude: location.latitude, radius: 10, sport: "soccer")
                                    session.events = eventObserver.events
                                    
                                }
                                
                                // prevents us from doing this everytime we get new info from gps
                                // thus we only load data the first time
                                // later i might add a button for you to reload, however, i dont see the need to
                                // unless you are in map view.
                                // TODO: Maybe add reload button to mapview
                                hasLoaded = true
                                
                                // stops the view from showing the template loader
                                fieldObserver.isLoading = false
                            }
                        }
                        .padding(.bottom, 100)
                        .task {
                            guard hasOpened == false else {
                                return
                            }
                            
                            locationManager.requestLocation()
                            
                            // mix stored user data with backend data
                            await session.GenerateUpdatedUserData()
                            
                            // grab clubs data
                            await session.generateClubsData()
                            
                            hasOpened = true
                            // makes sure we are only getting this data the first time only
                        }

                }.navigationTitle("Home")
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(SessionStore())
    }
}
