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
                Text("Recurrence Frequency")
                    .font(.headline)
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
                
                Stepper(value: $frequency) {
                    VStack(alignment: .leading) {
                        Text("Every \(frequency)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("How frequently should this event cycle?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }.padding([.top, .horizontal])
            }
            
            VStack(alignment: .leading) {
                Text("End Date")
                    .font(.headline)
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
        .onDisappear {
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
