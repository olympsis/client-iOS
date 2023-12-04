//
//  FieldDetailView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct FieldDetailView: View {
    
    @State var field: Field

    @State private var showNewEvent = false
    @State private var status: LOADING_STATE = .loading
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func leadToMaps() {
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[1]),\(field.location.coordinates[0])")! as URL)
    }
    
    var canCreateEvent: Bool {
        guard let user = session.user,
              let clubs = user.clubs,
              user.sports != nil,       // at least have a sport
              clubs.count > 0,          // at least have a club
              session.fields.count > 0, // at least one field in the area
              session.clubs.count > 0 else { // data for club has been fetched
            return false
        }
        return true
    }
    
    var ownershipStatus: String {
        if field.owner.type == "private" {
            return "Private"
        } else {
            return "Public"
        }
    }
    
    var fieldLocationString: String {
        return field.city + ", " + field.state
    }
    
    var fieldEvents: [Event] {
        return session.events.filter({ $0.fieldID == field.id })
    }
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    //MARK: - ASYNC Image
                    ZStack(alignment: .top){
                        AsyncImage(url: URL(string:  GenerateImageURL(field.images[0]))){ phase in
                            if let image = phase.image {
                                    image // Displays the loaded image.
                                        .resizable()
                                        .frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                
                                } else if phase.error != nil {
                                    Color.red // Indicates an error.
                                        .frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                                } else {
                                    Color.gray // Acts as a placeholder.
                                        .frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                                }
                        }
                    }
                    
                    //MARK: - Buttom view
                    HStack{
                        VStack(alignment: .leading){
                            
                            Text(field.name)
                                .font(.title2)
                                .bold()
                            
                            Text(fieldLocationString)
                                .foregroundColor(.gray)
                                .font(.body)
                                
                            Text(ownershipStatus)
                                .font(.caption2)
                                .foregroundColor(.red)
                                .bold()
                            
                        }.padding(.leading)
                            .frame(height: 45)
                        Spacer()
                        HStack {
                            Button(action:{leadToMaps()}){
                                ZStack{
                                    Image(systemName: "car")
                                        .resizable()
                                        .frame(width: 25, height: 20)
                                        .foregroundColor(.primary)
                                        .imageScale(.large)
                                }.padding(.trailing)
                            }
                        }
                        
                    }.padding(.top)
                    
                    Text(field.description)
                        .padding(.top)
                        .frame(width: SCREEN_WIDTH-25)
                        .font(.callout)
                    
                    if canCreateEvent {
                        HStack {
                            Spacer()
                            Button(action:{ self.showNewEvent.toggle() }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 120, height: 30)
                                        .foregroundColor(Color("color-prime"))
                                    Text("Create Event")
                                        .foregroundColor(.white)
                                }
                            }.padding(.trailing)
                                .padding(.top)
                        }
                    }
                    
                    //MARK: - Events View
                    VStack(alignment: .leading){
                        HStack {
                            Text("Events")
                                .font(.title3)
                                .bold()
                            .frame(height: 20)
                            Rectangle()
                                .frame(height: 1)
                        }.frame(width: SCREEN_WIDTH-25)
                        if session.events.isEmpty {
                            VStack(alignment: .center){
                                Text("There are no events at this field. 🥹")
                                    .padding(.all)
                            }.frame(width: SCREEN_WIDTH-25)
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
                            }.frame(width: SCREEN_WIDTH-25)
                        }
                    }.padding(.top, 50)
                }
                .sheet(isPresented: $showNewEvent) {
                    NewEvent()
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        Button(action:{}){
                            Label("Report an Issue", systemImage: "exclamationmark.shield")
                        }
                    }label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 25, height: 5)
                            .foregroundColor(Color(uiColor: .label))
                    }
                }
            }.task {
                status = .success
            }
            /*
            .refreshable {
                // MIGHT TURN OFF THIS FEATURE TILL I PUT IN FETCH EVENTS BY FIELD IN THE API
                
                guard let location = session.locationManager.location else {
                    return
                }
                await session.getNearbyData(location: location)
                 
            }*/
        }
    }
}

struct FieldDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FieldDetailView(field: FIELDS[0]).environmentObject(SessionStore())
    }
}
