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
    @State private var firstName = "User"
    @State private var hasLoaded = false // to make sure user location is updated once
    @State private var showDetail = false
    @State private var showMoreFields = false
    @State private var status: LOADING_STATE = .loading

    @StateObject private var observer = FeedObserver()
    @StateObject private var eventObserver = EventObserver()
    @StateObject private var fieldObserver = FieldObserver()
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    
                    //MARK: - Welcome message
                    HStack {
                        VStack(alignment: .leading){
                            WelcomeView(firstName: $firstName, status: $status)
                        }.padding(.top, 25)
                        Spacer()
                    }
                    
                    //MARK: - Announcements
                    HStack{
                        VStack(alignment: .leading){
                            Text("Announcements")
                                .font(.custom("Helvetica Neue", size: 17))
                                .bold()
                                .padding()
                            AnnouncementsView(status: $status, announcements: $observer.announcements)
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
                                FieldsList(fields: session.fieldObserver.fields)
                            }
                            
                            FieldsView(fields: $session.fieldObserver.fields, status: $status)
                        }
                    }.onReceive(session.locationManager.$location) { newLoc in
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
                            // grab user data and set first name for welcome message
                            guard let user = session.user, let firstName = user.firstName else {
                                log.error("failed to get user data")
                                return
                            }
                            self.firstName = firstName
                            
                            // fetch home view data such as fields/events
                            await session.fetchHomeViewData(location: location)
                            self.status = .success
                        }
                    }
                    .padding(.bottom, 100)
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
