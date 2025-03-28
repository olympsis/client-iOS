//
//  NewEventRecurringSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventRecurringSettings: View {
    
    @Bindable var manager: NewEventManager
    @State private var recurrenceEndDate: Date = Date()
    @State private var recurrenceFrequency: EVENT_RECURRENCE_FREQUENCY = .weekly
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Recurrence Frequency")
                    .font(.title3)
                    .bold()
                    .padding(.leading)
                Text("How often do you want this event to happen?")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.leading)
                
                HStack {
                    Button(action: { recurrenceFrequency = .weekly }) {
                        Text("WEEKLY")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.Background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.foreground, lineWidth: recurrenceFrequency == .monthly ? 0 : 2)
                    )
                    
                    Button(action: { recurrenceFrequency = .monthly }) {
                        Text("MONTHLY")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color.Background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.foreground, lineWidth: recurrenceFrequency == .monthly ? 2 : 0)
                    )
                    
                    Spacer()
                }.padding(.leading)
            }
            
            VStack(alignment: .leading) {
                Text("End Date")
                    .font(.title3)
                    .bold()
                    .padding(.leading)
                Text("When do you want the recurrence to stop?")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.leading)
                
                HStack {
                    DatePicker(
                        "Date",
                        selection: $recurrenceEndDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    
                    Spacer()
                }.padding(.leading)
            }.padding(.top)
            
            Spacer()
        }
        .padding(.top)
        .background(Color.Background.primary)
        .onDisappear {
            guard !Calendar.current.isDate(recurrenceEndDate, inSameDayAs: Date()) else {
                return
            }
            manager.recurrenceOptions = EventRecurrenceOptions(pattern: recurrenceFrequency, endTime: recurrenceEndDate, interval: 1)
        }
    }
}

#Preview {
    NewEventRecurringSettings(manager: NewEventManager())
}
