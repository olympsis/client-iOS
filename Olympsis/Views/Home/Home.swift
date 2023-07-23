//
//  Home.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import os
import SwiftUI
import CoreLocation
import NotificationCenter

struct Home: View {
    
    // status of loading event
    enum ViewStatus {
        case loading
        case failed
        case done
    }
    
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "home_view")
    @State private var fieldIndex = "0"
    @State private var hasLoaded = false // to make sure user location is updated once
    @State private var showDetail = false
    @State private var showOnboarding = false
    @State private var showMoreFields = false
    @State private var showNotifications = false
    @State private var status: LOADING_STATE = .loading
    
    @EnvironmentObject var session: SessionStore
    
    @AppStorage("eventDetailOnboarding") var onboarding:Bool?
    
    private var name: String {
        guard let user = session.user, let name = user.firstName else {
            log.error("failed to get user's name")
            return ""
        }
        return name
    }
    
    private var event: Event? {
        guard let user = session.user,
              let uuid = user.uuid else {
            return nil
        }
        
        return session.events.mostRecentForUser(uuid: uuid)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    
                    //MARK: - Welcome message
                    HStack {
                        VStack(alignment: .leading){
                            WelcomeView(name: name, status: $status)
                        }.padding(.top, 25)
                        Spacer()
                    }
                    
                    if let e = event {
                        if status == .success {
                            VStack (alignment: .center){
                                EventView(event: e)
                            }
                        }
                    }
                    
                    //MARK: - Announcements
                    HStack{
                        VStack(alignment: .leading){
                            Text("Announcements")
                                .font(.custom("Helvetica Neue", size: 17))
                                .bold()
                                .padding()
                            AnnouncementsView(status: $status, announcements: $session.feedObserver.announcements)
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
                                Button(action:{self.showMoreFields.toggle()}){
                                    Text("View All")
                                       .bold()
                                    Image(systemName: "chevron.down")
                                }.padding()
                                    .foregroundColor(Color.primary)
                            }.fullScreenCover(isPresented: $showMoreFields) {
                                FieldsList(fields: session.fields)
                            }
                            
                            FieldsView(fields: $session.fields, status: $status)
                        }
                    }.onReceive(session.locationManager.$location) { newLoc in
                        
                        // make sure new location is valid
                        guard let location = newLoc else {
                            return
                        }
                        
                        // we have to wait an undetermined amount of time to hear back from the gps to get location
                        // so i used on recieve and after that info is delivered we can start fetching for fields by location
                        guard hasLoaded == false else {
                            return
                        }
                        
                        // prevents us from doing this everytime we get new info from gps
                        // thus we only load data the first time
                        // later i might add a button for you to reload, however, i dont see the need to
                        // unless you are in map view.
                        hasLoaded = true
                        
                        Task {
                            // fetch home view data such as fields/events
                            await session.getNearbyData(location: location)
                            await session.generateUserData()
                            
                            // fetch club data
                            await session.fetchUserClubs()
                            self.status = .success
                        }
                    }
                    .padding(.bottom, 100)
                    .task {
                        guard onboarding != nil else {
                            showOnboarding = true
                            onboarding = true
                            return
                        }
                    }
                }.fullScreenCover(isPresented: $showNotifications, content: {
                    NotificationsView()
                })
                .fullScreenCover(isPresented: $showOnboarding, content: {
                    FindingEvents()
                })
            }.toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Olympsis")
                        .font(.custom("ITCAvantGardeStd-Bold", size: 30, relativeTo: .largeTitle))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{ self.showNotifications.toggle() }) {
                        Image(systemName: "bell")
                            
                    }
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(SessionStore())
    }
}
