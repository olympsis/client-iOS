//
//  NewEventRecurringSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventRecurringSettings: View {

    /// Whether the event repeats at all. Previously there was no such switch:
    /// the sheet inferred "not repeating" from the end date still being today,
    /// which meant a user who opened the sheet and picked any other date could
    /// not turn the repeat back off.
    @State private var isRepeating: Bool = false

    @State private var frequency: Int = 1
    @State private var recurrenceEndDate: Date = Date()
    @State private var recurrenceFrequency: EVENT_RECURRENCE_FREQUENCY = .weekly

    @Environment(NewEventManager.self) private var manager

    /// A sensible first end date: a week out from the event. Only used to seed
    /// the picker the first time the toggle is switched on.
    private var defaultEndDate: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: 1, to: manager.startDate) ?? manager.startDate
    }

    var body: some View {
        VStack {
            Toggle(isOn: $isRepeating.animation()) {
                VStack(alignment: .leading) {
                    Text(String(localized: "advanced-settings-recurrence-toggle", defaultValue: "Repeat this event", table: "Events"))
                        .font(.headline)
                        .bold()
                    Text(String(localized: "advanced-settings-recurrence-toggle-desc", defaultValue: "Create the same event again on a schedule.", table: "Events"))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            .onChange(of: isRepeating) { _, enabled in
                // Seed the end date the first time this is switched on so the
                // picker never starts on a date that fails validation.
                if enabled && recurrenceEndDate <= manager.startDate {
                    recurrenceEndDate = defaultEndDate
                }
            }

            if isRepeating {
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
                        ForEach(EVENT_RECURRENCE_FREQUENCY.allCases, id: \.self) { option in
                            Button(action: { recurrenceFrequency = option }) {
                                Text(option.displayName())
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.Background.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.Foreground.default, lineWidth: recurrenceFrequency == option ? 2 : 0)
                            )
                        }

                        Spacer()
                    }.padding(.leading)

                    // Bounded: the server rejects an interval below 1, and 52
                    // covers a full year at the coarsest useful step.
                    Stepper(value: $frequency, in: 1...52) {
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
                        // Bounded by the event's own start so the repeat can't
                        // be set to end before the first occurrence happens.
                        DatePicker(
                            "Date",
                            selection: $recurrenceEndDate,
                            in: manager.startDate...,
                            displayedComponents: [.date]
                        )
                            .datePickerStyle(.compact)
                            .labelsHidden()

                        Spacer()
                    }.padding(.leading)
                }.padding(.top)
            }

            Spacer()
        }
        .padding(.top)
        .onAppear {
            // Load in data from manager if it exists
            guard let config = manager.recurrenceOptions else {
                recurrenceEndDate = defaultEndDate
                return
            }
            isRepeating = true
            recurrenceFrequency = config.pattern
            recurrenceEndDate = config.endTime
            frequency = config.interval
        }
        .onDisappear {
            // Make sure we update the manager on dismissal of this view.
            // Writing nil when the toggle is off is what actually clears a
            // recurrence the user changed their mind about.
            manager.recurrenceOptions = isRepeating
                ? EventRecurrenceOptions(
                    pattern: recurrenceFrequency,
                    endTime: recurrenceEndDate,
                    interval: frequency
                  )
                : nil
        }
    }
}

#Preview {
    NewEventRecurringSettings()
        .environment(NewEventManager())
}
