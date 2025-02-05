//
//  EventMiddleView.swift
//  Olympsis
//
//  Created by Joel on 11/12/23.
//

import SwiftUI

/// A view that shows the status and participant info about an event
struct EventMiddleView: View {
    
    @State private var isBlinking: Bool = false
    @State private var timeDifference: String = ""
    @EnvironmentObject private var event: Event
    
    var startTime: Int {
        return event.startTime;
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
        let startDate = Date(timeIntervalSince1970: TimeInterval(event.startTime))
        let time = Calendar.current.dateComponents([.minute], from: startDate, to: Date.now)
        if let min = time.minute {
            return min
        }
        return 1
    }
    
    var eventLevel: Int {
        return event.level.toInt()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .padding(.horizontal)
                .frame(height: 70)
                .foregroundStyle(Color("background"))
            HStack (alignment: .center) {
                VStack(alignment: .center){
                    switch event.getEventStatus() {
                    case .pending:
                        VStack {
                            Text("Pending")
                                .foregroundColor(.yellow)
                            Text(Date(timeIntervalSince1970: TimeInterval(startTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.green)
                                .bold()
                        }
                    case .live:
                        HStack {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.red)
                                .opacity(isBlinking ? 0 : 1)
                                .onAppear {
                                    withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                                        isBlinking.toggle()
                                    }
                                }
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
                    case .ended:
                        VStack {
                            Text("Ended")
                                .foregroundColor(.gray)
                                .bold()
                            Text(Date(timeIntervalSince1970: TimeInterval(event.stopTime)).formatted(.dateTime.hour().minute()))
                                .foregroundColor(.primary)
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
                }
                
                Spacer()
                
                EventLevelView(level: eventLevel)
                
            }.padding(.horizontal)
        }.frame(maxWidth: .infinity)
            .padding(.bottom)
    }
}

#Preview {
    EventMiddleView()
        .environmentObject(EVENTS[0])
}
