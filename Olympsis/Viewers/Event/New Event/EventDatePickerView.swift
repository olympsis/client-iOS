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
    
    var body: some View {
        VStack(alignment: .leading){
            DatePicker("Date", selection: $eventTime, in: startingPoint...)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
        }
    }
}

#Preview {
    EventDatePickerView(eventTime: .constant(Date()))
}
