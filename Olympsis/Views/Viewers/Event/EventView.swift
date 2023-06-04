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
    @State var status: Status = .loading
    @State var showDetails = false
    
    @Binding var events: [Event]
    
    var title: String {
        guard let title = event.title else {
            return "Event"
        }
        return title
    }
    
    var eventBody: String {
        guard let b = event.body else {
            return "Event Body"
        }
        return b
    }
    
    var eventLevel: Int {
        guard let level = event.level else {
            return 1
        }
        return level
    }
    
    var imageURL: String {
        guard let img = event.imageURL else {
            return ""
        }
        return img
    }
    
    var city: String {
        guard let data = event.data,
              let field = data.field else {
            return "City"
        }
        return field.city
    }
    
    var state: String {
        guard let data = event.data,
              let field = data.field else {
            return "City"
        }
        return field.state
    }
    
    var fieldName: String {
        guard let data = event.data,
              let field = data.field else {
            return "Field Name"
        }
        return field.name
    }
    
    var startTime: Int64 {
        guard let time = event.startTime else {
            return 0
        }
        return time
    }
    
    func convertTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        if let t = event.actualStartTime {
            let date = Date(timeIntervalSince1970: TimeInterval(t))
            return formatter.string(from: date)
        } else {
            guard let sTime = event.startTime else {
                return ""
            }
            let date = Date(timeIntervalSince1970: TimeInterval(sTime))
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
        Button(action:{ self.showDetails.toggle() }) {
            VStack {
                VStack(alignment: .leading){
                    HStack {
                        Image(imageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.leading)
                        VStack(alignment: .leading){
                            Text(title)
                                .font(.custom("Helvetica-Nue", size: 20))
                                .bold()
                                .frame(height: 20)
                                .padding(.top)
                                .foregroundColor(.primary)
                            Text(fieldName)
                                .foregroundColor(.gray)
                            
                            switch(eventLevel){
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
                            Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
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
            EventDetailView(event: $event, events: $events)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: EVENTS[0], events: .constant([Event]()))
    }
}
