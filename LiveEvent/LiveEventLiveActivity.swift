//
//  LiveEventLiveActivity.swift
//  LiveEvent
//
//  Created by Joel on 9/30/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveEventAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var participants: Int
    }

    // Fixed non-changing properties about your activity go here!
    var eventTitle: String
    var hostingClubName: String
    var startTime: Int64
}

struct LiveEventLiveActivity: Widget {
    
    func renderTimePassed(context: LiveEventAttributes) -> Int {
        let startDate = Date(timeIntervalSince1970: TimeInterval(context.startTime))
        let time = Calendar.current.dateComponents([.minute], from: startDate, to: Date.now)
        if let min = time.minute {
            return min
        }
        return 1
    }
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveEventAttributes.self) { context in
            VStack (alignment: .leading) {
                Text(context.attributes.eventTitle)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("textColor"))
                Text(context.attributes.hostingClubName)
                    .foregroundColor(Color("textColor"))
                
                Text("00:00:00")
                    .bold()
                    .italic()
                    .foregroundColor(Color("center-color"))
                    .font(.custom("ITCAvantGardeStd-BoldObl", size: 35, relativeTo: .largeTitle))
                    .padding(.vertical, 3)
                HStack {
                    Spacer()
                    Image(systemName: "person.2")
                    Text("\(context.state.participants)")
                        .bold()
                }.foregroundColor(Color("textColor"))
                
            }.padding(.vertical)
                .padding(.horizontal, 30)
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
            .background {
                Color("background")
            }

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Image(systemName: "person.2")
                        Text("\(context.state.participants)")
                            .bold()
                    }.padding(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.eventTitle)
                    Text("00:00:00")
                        .bold()
                        .italic()
                        .foregroundColor(Color("secondaryColor"))
                        .font(.custom("ITCAvantGardeStd-BoldObl", size: 35, relativeTo: .largeTitle))
                        .padding(.vertical, 3)
                }
            } compactLeading: {
                Text("00:00")
                    .bold()
                    .italic()
                    .foregroundColor(Color("secondaryColor"))
                    .font(.custom("ITCAvantGardeStd-BoldObl", size: 15, relativeTo: .body))
                    .padding(.leading)
            } compactTrailing: {
                HStack {
                    Image(systemName: "person.2")
                    Text("\(context.state.participants)")
                        .bold()
                }
            } minimal: {
                // short time in minutes
                Text("00")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveEventAttributes {
    fileprivate static var preview: LiveEventAttributes {
        LiveEventAttributes(eventTitle: "Pick Up Soccer", hostingClubName: "SLC FC", startTime: 1000)
    }
}

extension LiveEventAttributes.ContentState {
    fileprivate static var regular: LiveEventAttributes.ContentState {
        LiveEventAttributes.ContentState(participants: 32)
     }
     
     fileprivate static var starEyes: LiveEventAttributes.ContentState {
         LiveEventAttributes.ContentState(participants: 4)
     }
}

#Preview("Notification", as: .content, using: LiveEventAttributes.preview) {
   LiveEventLiveActivity()
} contentStates: {
    LiveEventAttributes.ContentState.regular
}
