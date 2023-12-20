//
//  EventMiddleView.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import SwiftUI

/// A view that shows the status and participant info about an event
struct EventMiddleView: View {
    
    @Binding var event: Event
    @State private var timeDifference: String = ""
    
    var startTime: Int {
        guard let time = event.startTime else {
            return 0
        }
        return time
    }
    
    var participantsCount: Int {
        guard let partcipants = event.participants else {
            return 0
        }
        return partcipants.count
    }
    
    var minParticipantsCount: Int {
        guard let min = event.minParticipants else {
            return 0
        }
        return min
    }
    
    var maxParticipantsCount: Int {
        guard let max = event.maxParticipants else {
            return 0
        }
        return max
    }
    
    var participantsCountString: String {
        if maxParticipantsCount == 0 {
            return "\(participantsCount)/∞"
        } else {
            return "\(participantsCount)/\(maxParticipantsCount)"
        }
    }
    
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
    
    var eventLevel: Int {
        guard let level = event.level else {
            return 0
        }
        return level
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                .padding(.horizontal)
                .frame(height: 70)
                .foregroundStyle(Color("color-prime"))
            HStack (alignment: .center) {
                VStack(alignment: .center){
                    if event.actualStopTime != nil {
                        VStack {
                            Text("Ended")
                                .foregroundColor(.gray)
                                .bold()
                            if let sT = event.actualStopTime {
                                Text(Date(timeIntervalSince1970: TimeInterval(sT)).formatted(.dateTime.hour().minute()))
                                    .foregroundColor(.primary)
                                    .bold()
                            }
                        }
                    } else if event.actualStartTime != nil {
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.red)
                            Text("Live")
                                .bold()
                                .foregroundColor(.red)
                        }
                        Text("\(timeDifference)")
                            .foregroundColor(.primary)
                            .bold()
                            .onAppear {
                                timeDifference = event.timeDifferenceToString()
                                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { t in
                                    timeDifference = event.timeDifferenceToString()
                                }
                            }
                    } else if minParticipantsCount != 0 && participantsCount < minParticipantsCount {
                        VStack {
                            Text("Pending")
                                .foregroundColor(.yellow)
                            Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.green)
                                .bold()
                        }
                    } else {
                        VStack {
                            Text("Game On!")
                                .foregroundColor(Color("color-prime"))
                            Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.green)
                                .bold()
                        }
                    }
                }.padding(.leading)
                    .padding(.all, 7)
                
                Spacer()
                
                VStack {
                    VStack {
                        Image(systemName: "person.2.fill")
                        Text(participantsCountString)
                    }
                    .disabled(event.actualStopTime != nil)
                }
                
                Spacer()
                
                EventLevelView(level: eventLevel)
                
            }.padding(.horizontal)
        }.frame(maxWidth: .infinity)
            .padding(.bottom)
    }
}

#Preview {
    EventMiddleView(event: .constant(EVENTS[0]))
}
