//
//  LogListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/9/24.
//

import SwiftUI

struct LogListItem: View {
    
    var entry: LogEntry
    var timeAgo: String {
        let currentDate = Date()
        let difference = currentDate.timeIntervalSince(entry.date)
        
        if difference < 60 {
            return "\(Int(difference)) secs ago"
        } else {
            return "\(Int(difference / 60)) mins ago"
        }
    }
    var color: Color {
        if entry.level == "Error" {
            return .red
        } else if entry.level == "Info" {
            return .green
        } else if entry.level == "Debug" {
            return .yellow
        } else if entry.level == "Notice" {
            return .orange
        } else if entry.level == "Fault" {
            return .gray
        }
        return .black
    }
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Text(entry.level)
                        .bold()
                        .font(.caption)
                        .foregroundStyle(color)
                    Text(timeAgo)
                        .bold()
                        .font(.caption2)
                }.padding(.top, 4)
                Text(entry.category)
                    .font(.subheadline)
            }
                
            VStack(alignment: .leading) {
                Text(entry.subsystem)
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .italic()
                Text(entry.message)
                    .font(.callout)
            }
            Spacer()
        }.padding(.horizontal, 5)
    }
}

#Preview {
    LogListItem(
        entry: LogEntry(
            date: Date.now, 
            level: "Error",
            message: "Failed to create ",
            category: "event_creator",
            subsystem: "com.olympsis.client"
        )
    )
}
