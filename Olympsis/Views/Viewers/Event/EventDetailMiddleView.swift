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
    
    var startTime: Int64 {
        guard let time = event.startTime else {
            return 0
        }
        return time
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
                            Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.green)
                                .bold()
                        }
                    } else if event.status == "ended" {
                        VStack {
                            Text("Ended")
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
        EventDetailMiddleView(event: .constant(EVENTS[0]))
    }
}
