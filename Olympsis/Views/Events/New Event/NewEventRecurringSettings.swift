//
//  NewEventRecurringSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventRecurringSettings: View {
    
    @State private var frequency: Int = 1
    @State private var recurrenceEndDate: Date = Date()
    @State private var recurrenceFrequency: EVENT_RECURRENCE_FREQUENCY = .weekly
    
    @Environment(NewEventManager.self) private var manager
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(String(localized: "advanced-settings-recurrence-frequency-title", table: "Events"))
                    .font(.headline)
                    .bold()
                    .padding(.leading)
                Text(String(localized: "advanced-settings-recurrence-frequency-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.leading)
                
                HStack {
                    Button(action: { recurrenceFrequency = .weekly }) {
                        Text(String(localized: "advanced-settings-recurrence-frequency-weekly", table: "Events"))
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
                        Text(String(localized: "advanced-settings-recurrence-frequency-monthly", table: "Events"))
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
                
                Stepper(value: $frequency) {
                    VStack(alignment: .leading) {
                        Text("\(String(localized: "advanced-settings-recurrence-every-title", table: "Events")) \(frequency)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(String(localized: "advanced-settings-recurrence-frequency-sub-title", table: "Events"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }.padding([.top, .horizontal])
            }
            
            VStack(alignment: .leading) {
                Text(String(localized: "advanced-settings-recurrence-end-date-title", table: "Events"))
                    .font(.headline)
                    .bold()
                    .padding(.leading)
                Text(String(localized: "advanced-settings-recurrence-end-date-sub-title", table: "Events"))
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
        .onAppear {
            // Load in data from manager if it exists
            guard let config = manager.recurrenceOptions else { return }
            recurrenceFrequency = config.pattern
            recurrenceEndDate = config.endTime
            frequency = config.interval
        }
        .onDisappear {
            // Make sure we update the manager on dismissal of this view
            guard !Calendar.current.isDate(recurrenceEndDate, inSameDayAs: Date()) else {
                return
            }
            manager.recurrenceOptions = EventRecurrenceOptions(
                pattern: recurrenceFrequency,
                endTime: recurrenceEndDate,
                interval: frequency
            )
        }
    }
}

#Preview {
    NewEventRecurringSettings()
        .environment(NewEventManager())
}
