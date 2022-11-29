//
//  FieldDetailView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct FieldDetailView: View {
    
    // status of loading events
    enum Status {
        case loading
        case failed
        case done
    }
    
    @State var field: Field
    @State private var events = [Event]()

    @State private var showNewEvent = false
    @State private var status: Status = .loading
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func leadToMaps() {
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[0]),\(field.location.coordinates[1])")! as URL)
    }
    
    func fetchEvents() async -> [Event]? {
        return session.events.filter{$0.fieldId == field.id}
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    //MARK: - ASYNC Image
                    ZStack(alignment: .top){
                        AsyncImage(url: URL(string: field.images[0])){ phase in
                            if let image = phase.image {
                                    image // Displays the loaded image.
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                } else if phase.error != nil {
                                    Color.red // Indicates an error.
                                        .cornerRadius(10)
                                } else {
                                    Color.gray // Acts as a placeholder.
                                        .cornerRadius(10)
                                }
                        }.frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                    }.frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
                    
                    //MARK: - Buttom view
                    HStack{
                        VStack(alignment: .leading){
                            HStack {
                                Text(field.name)
                                    .font(.title2)
                            }.frame(height: 20)
                            Text(field.city)
                                .font(.title3)
                                .foregroundColor(.gray)
                                .frame(height: 20)
                            if field.isPublic {
                                Text("Public")
                                    .foregroundColor(.green)
                                    .bold()
                            } else {
                                Text("Private")
                                    .foregroundColor(.red)
                                    .bold()
                            }
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
                    
                    Text(field.notes)
                        .padding(.top)
                        .frame(width: SCREEN_WIDTH-25)
                        .font(.callout)
                    
                    HStack {
                        Spacer()
                        Button(action:{self.showNewEvent.toggle()}) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 120, height: 30)
                                    .foregroundColor(Color("primary-color"))
                                Text("Create Event")
                                    .foregroundColor(.white)
                            }
                        }.padding(.trailing)
                            .padding(.top)
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
                        if events.isEmpty {
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
                                } else if status == .failed {
                                    Text("Failed to load events")
                                        .foregroundColor(.red)
                                        .padding(.top)
                                }else {
                                    ForEach(events) { event in
                                        EventView(event: event, field: field, events: $events)
                                    }
                                }
                            }.frame(width: SCREEN_WIDTH-25)
                        }
                    }.padding(.top, 50)
                }.task {
                    self.events = session.events.filter{$0.fieldId == self.field.id}
                    self.status = .done
                }
                .sheet(isPresented: $showNewEvent) {
                    NewEventView()
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
            }
        }
    }
}

struct FieldDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let field = Field(id: "", owner: "", name: "Richard Building Fields", notes: "The Richard Building Fields is a private field owned by Brigham Young Univeristy. It has a newly installed turf field. It's often used as the football team's practice field. Parking is available near the field; however it's restricted. It's available on weekdays after 4pm and it's free on the wekends.", sports: [""], images: [""], location: GeoJSON(type: "", coordinates: [0.0]), city: "Provo", state: "Orem", country: "", isPublic: false)
        FieldDetailView(field: field).environmentObject(SessionStore())
    }
}
