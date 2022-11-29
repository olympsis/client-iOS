//
//  EventDetailMiddleView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import SwiftUI

struct EventDetailMiddleView: View {
    
    @Binding var event: Event
    @State private var isBlinking = false
    @State private var timeDifference = 0
    
    func getTimeDifference() -> Int {
        guard let startTime = event.actualStartTime else {
            return 2
        }
        let startDate = Date(timeIntervalSince1970: TimeInterval(startTime))
        let time = Calendar.current.dateComponents([.minute], from: startDate, to: Date.now)
        if let min = time.minute {
            return min
        }
        return 1
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: SCREEN_WIDTH - 50,height: 2)
                .foregroundColor(.white)
            HStack (alignment: .center){
                VStack(alignment: .center){
                    if event.status == "in-progress" {
                        HStack {
                            Circle()
                                .frame(width: 10)
                                .foregroundColor(.red)
                            Text("Live")
                                .bold()
                            .foregroundColor(.red)
                            
                        }
                        Text("\(getTimeDifference()) mins")
                            .foregroundColor(.white)
                            .bold()
                    } else if event.status == "pending"{
                        VStack {
                            Text("Pending")
                                .foregroundColor(Color("primary-color"))
                            Text(Date(timeIntervalSince1970: TimeInterval(event.startTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.green)
                                .bold()
                        }
                    } else if event.status == "completed" {
                        VStack {
                            Text("Completed")
                                .foregroundColor(.gray)
                                .bold()
                            if let sT = event.stopTime {
                                Text(Date(timeIntervalSince1970: TimeInterval(sT)).formatted(.dateTime.hour().minute()))
                                    .foregroundColor(.white)
                                    .bold()
                            }
                        }
                    }
                }.frame(width: 100)
                    .padding(.leading)
                Rectangle()
                    .frame(width: 2, height: 50)
                    .foregroundColor(.white)
                Rectangle()
                    .frame(width: 2, height: 50)
                    .foregroundColor(.white)
                    .padding(.leading, SCREEN_WIDTH/3)
                
                VStack(alignment: .center){
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
                    
                    Text("level")
                        .foregroundColor(.white)
                        .bold()
                }.frame(width: 100)
                    .padding(.trailing)
            }
            Rectangle()
                .frame(width: SCREEN_WIDTH - 50,height: 2)
                .foregroundColor(.white)
        }.frame(width: SCREEN_WIDTH - 50)
    }
}

struct EventDetailMiddleView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(id: "", owner: Owner(uuid: "", username: "unnamed_user", imageURL: ""), clubId: "", fieldId: "", imageURL: "", title: "event", body: "eventBody", sport: "soccer", level: 3, status: "in-progress", startTime: 1669763400, actualStartTime: 1669759200, maxParticipants: 0)
        EventDetailMiddleView(event: .constant(event))
            .background {
                Color.black
            }
    }
}
