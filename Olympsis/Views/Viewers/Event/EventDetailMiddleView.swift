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
                .foregroundColor(.primary)
            HStack (alignment: .center){
                VStack(alignment: .center){
                    if event.status == "in-progress" {
                        HStack {
                            BlinkingCircle()
                                .frame(width: 10, height: 10)
                            Text("Live")
                                .bold()
                            .foregroundColor(.red)
                            
                        }
                        Text("\(timeDifference) mins")
                            .foregroundColor(.primary)
                            .bold()
                            .onAppear {
                                timeDifference = getTimeDifference()
                                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { t in
                                    timeDifference = getTimeDifference()
                                }
                            }
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
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                        }
                    }
                }.frame(width: 100)
                    .padding(.leading)
                Rectangle()
                    .frame(width: 2, height: 50)
                    .foregroundColor(.primary)
                Rectangle()
                    .frame(width: 2, height: 50)
                    .foregroundColor(.primary)
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
                        .foregroundColor(.primary)
                        .bold()
                }.frame(width: 100)
                    .padding(.trailing)
            }
            Rectangle()
                .frame(width: SCREEN_WIDTH - 50,height: 2)
                .foregroundColor(.primary)
        }.frame(width: SCREEN_WIDTH - 50)
    }
}

struct EventDetailMiddleView_Previews: PreviewProvider {
    static var previews: some View {
        let peek = UserPeek(firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "", sports: ["soccer"])
        let _ = Club(id: "", name: "International Soccer Utah", description: "A club in provo to play soccer.", sport: "soccer", city: "Provo", state: "Utah", country: "United States of America", imageURL: "", isPrivate: false, members: [Member](), rules: ["No fighting"], createdAt: 0)
        let event = Event(id: "", ownerId: "", ownerData: peek, clubId: "", fieldId: "", imageURL: "", title: "event", body: "eventBody", sport: "soccer", level: 3, status: "in-progress", startTime: 1669763400, actualStartTime: 1669759200, maxParticipants: 0)
        EventDetailMiddleView(event: .constant(event))
    }
}
