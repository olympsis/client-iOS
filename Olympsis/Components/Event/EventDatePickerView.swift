//
//  EventStartDatePicker.swift
//  Olympsis
//
//  Created by Joel on 12/22/23.
//

import SwiftUI

struct EventDatePickerView: View {
    
    @Binding var eventTime: Date
    @State var startingPoint: Date = Date()

    /// Which components the picker exposes. Defaults to both date and time so
    /// existing callers keep the original full-calendar behavior.
    var displayedComponents: DatePickerComponents = [.date, .hourAndMinute]

    var body: some View {
        VStack(alignment: .leading){
            if displayedComponents == .hourAndMinute {
                // Time-only selection uses the wheel style; the graphical
                // style does not render a standalone time picker.
                DatePicker("Date", selection: $eventTime, in: startingPoint..., displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
            } else {
                DatePicker("Date", selection: $eventTime, in: startingPoint..., displayedComponents: displayedComponents)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
            }
        }
    }
}

#Preview {
    EventDatePickerView(eventTime: .constant(Date()))
}
