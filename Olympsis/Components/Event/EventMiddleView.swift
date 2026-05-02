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
    @Environment(Event.self) private var event: Event
    
    var startTime: Date {
        return event.startTime;
    }
    
    var participantsCount: Int {
        return event.participants.count
    }
    
    var minParticipantsCount: Int {
        guard let min = event.participantsConfig?.minParticipants else {
            return 0
        }
        return Int(min)
    }
    
    var maxParticipantsCount: Int {
        guard let max = event.participantsConfig?.maxParticipants else {
            return 0
        }
        return Int(max)
    }
    
    var participantsCountString: String {
        if maxParticipantsCount == 0 {
            return "\(participantsCount)/∞"
        } else {
            return "\(participantsCount)/\(maxParticipantsCount)"
        }
    }
    
    func getTimeDifference() -> Int {
        let time = Calendar.current.dateComponents([.minute], from: event.startTime, to: Date.now)
        if let min = time.minute {
            return min
        }
        return 1
    }
    
    var eventLevel: Int {
        return 0
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .padding(.horizontal)
                .frame(height: 70)
                .foregroundStyle(Color.Background.secondary)
            HStack (alignment: .center) {
                VStack(alignment: .center){
                    switch event.getEventStatus() {
                    case .pending:
                        VStack {
                            Text(String(localized: "status-pending", table: "Events"))
                                .foregroundColor(.yellow)
                            Text(startTime.formatted(.dateTime.hour().minute()))
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
                            Text(String(localized: "status-live", table: "Events"))
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
                            Text(String(localized: "status-ended", table: "Events"))
                                .foregroundColor(.gray)
                                .bold()
                            Text(event.stopTime.formatted(.dateTime.hour().minute()))
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
        .environment(EVENTS[0])
}
