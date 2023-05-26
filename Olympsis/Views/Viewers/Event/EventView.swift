//
//  EventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EventView: View {
    
    // status of loading event
    enum Status {
        case loading
        case failed
        case done
    }
    
    @State var event: Event
    @State var field: Field
    @State var status: Status = .loading
    @State var showDetails = false
    
    @Binding var events: [Event]
    
    func convertTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        if let t = event.actualStartTime {
            let date = Date(timeIntervalSince1970: TimeInterval(t))
            return formatter.string(from: date)
        } else {
            let date = Date(timeIntervalSince1970: TimeInterval(event.startTime))
            return formatter.string(from: date)
        }
    }
    
    func getParticipantsCount() -> Int {
        if let p = event.participants {
            return p.count
        } else {
            return 0
        }
    }
    
    var body: some View {
        Button(action:{self.showDetails.toggle()}) {
            VStack {
                VStack(alignment: .leading){
                    HStack {
                        Image(event.imageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.leading)
                        VStack(alignment: .leading){
                            Text(event.title)
                                .font(.custom("Helvetica-Nue", size: 20))
                                .bold()
                                .frame(height: 20)
                                .padding(.top)
                                .foregroundColor(.primary)
                            Text(field.name)
                                .foregroundColor(.gray)
                            
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
                            
                            Spacer()
                        }
                        Spacer()
                        VStack (alignment: .trailing){
                            Text(Date(timeIntervalSince1970: TimeInterval(event.startTime)).formatted(.dateTime.hour().minute()))
                                .bold()
                                .padding(.bottom)
                                .foregroundColor(.primary)
                            HStack {
                                Image(systemName: "person.3.sequence.fill")
                                    .foregroundColor(Color("primary-color"))
                                Text("\(getParticipantsCount())")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.trailing)
                    }
                }.frame(height: 100)
            }
        }.fullScreenCover(isPresented: $showDetails) {
            EventDetailView(event: $event, field: field, events: $events)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let _ = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "", isPrivate: false, members: [Member](), rules: ["No fighting"], createdAt: 0)
        EventView(event: Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "soccer-2", title: "Pick Up Soccer", body: "event-body", sport: "soccer", level: 0, status: "pending", startTime: 0, maxParticipants: 0),field: FIELDS[0], events: .constant([Event]()))
    }
}
