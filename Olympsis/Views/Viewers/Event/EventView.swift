//
//  EventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EventView: View {
    
    @State var event: Event
    @State var status: LOADING_STATE = .loading
    @State var showDetails = false
    @EnvironmentObject var session:SessionStore
    
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
    
    var participantsCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        return participants.count
    }
    
    var eventDay: String {
        guard let eventStatus = event.status,
              let eventStartTime = event.startTime else {
            return "0/0/0"
        }
        
        if eventStatus == "in-progress" {
            guard event.actualStartTime == nil else {
                return "Live"
            }
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let timestamp = TimeInterval(eventStartTime)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/y"
        
        if calendar.isDateInToday(Date(timeIntervalSince1970: timestamp)) {
            return "Today"
        } else if calendar.isDateInTomorrow(Date(timeIntervalSince1970: timestamp)) {
            return "Tomorrow"
        } else if calendar.isDate(Date(timeIntervalSince1970: timestamp), equalTo: currentDate, toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: Date(timeIntervalSince1970: timestamp))
        } else if calendar.isDate(Date(timeIntervalSince1970: timestamp), equalTo: currentDate, toGranularity: .year) {
            return formatter.string(from: Date(timeIntervalSince1970: timestamp))
        } else {
            return formatter.string(from: Date(timeIntervalSince1970: timestamp))
        }
    }
    
    var eventTime: String {
        guard let eventStatus = event.status,
              let eventStartTime = event.startTime else {
            return "00:00am"
        }
        
        if eventStatus == "in-progress" {
            guard event.actualStartTime != nil else {
                return "00 secs"
            }
            let currentDate = Date()
            let timeDifference = Int(currentDate.timeIntervalSince1970 - TimeInterval(event.actualStartTime!))
            
            if timeDifference < 60 {
                return "\(timeDifference) secs"
            } else if timeDifference < 3600 {
                let minutes = timeDifference / 60
                return "\(minutes) mins"
            } else {
                let hours = timeDifference / 3600
                return "\(hours) hrs"
            }
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(eventStartTime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
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
                            VStack (alignment: .trailing){
                                Text(eventDay)
                                    .bold()
                                    .font(.callout)
                                    .foregroundColor(.primary)
                                Text(eventTime)
                                    .foregroundColor(.primary)
                            }.padding(.bottom, 5)
                            
                            HStack {
                                Image(systemName: "person.3.sequence.fill")
                                    .foregroundColor(Color("primary-color"))
                                Text("\(participantsCount)")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.trailing)
                    }
                }.frame(height: 100)
            }
        }.clipShape(Rectangle())
        .fullScreenCover(isPresented: $showDetails) {
            EventDetailView(event: $event)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: EVENTS[0]).environmentObject(SessionStore())
    }
}
