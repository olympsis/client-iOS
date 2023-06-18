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
    
    var eventDate: String {
        guard let eventStatus = event.status,
              var eventStartTime = event.startTime else {
            return "0:00 PM"
        }
        
        if eventStatus == "in-progress" {
            guard let actualStartTime = event.actualStartTime else {
                return "0:00 PM"
            }
            eventStartTime = actualStartTime
        }
        
        let currentDate = Date()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        let currentDay = calendar.component(.day, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        
        let date = Date(timeIntervalSince1970: TimeInterval(eventStartTime))
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
//        let hour = calendar.component(.hour, from: date)
//        let minute = calendar.component(.minute, from: date)
        
        if currentYear == year {
            if currentDay == day && currentMonth == month {
                formatter.dateFormat = "h:mm a"
                return formatter.string(from: date)
            } else if currentDay - 1 == day && currentMonth == month {
                return "Yesterday"
            } else if currentDay + 1 == day && currentMonth == month {
                return "Tomorrow"
            } else {
                formatter.dateFormat = "MMM d"
                let monthString = formatter.string(from: date)
                return "\(monthString), \(year)"
            }
        } else {
            formatter.dateFormat = "MMM d"
            let monthString = formatter.string(from: date)
            return "\(monthString), \(year)"
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
                            Text("\(eventDate)")
                                .bold()
                                .padding(.bottom)
                                .foregroundColor(.primary)
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
        }.fullScreenCover(isPresented: $showDetails) {
            EventDetailView(event: $event)
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: EVENTS[0]).environmentObject(SessionStore())
    }
}
