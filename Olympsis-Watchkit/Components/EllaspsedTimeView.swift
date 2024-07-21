//
//  EllaspsedTimeView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct EllaspsedTimeView: View {
    
    var ellapsedTime: TimeInterval = 0
    var showSubSeconds: Bool = true
    @State private var timeFormatter = EllapsedTimeFormatter()
    
    var body: some View {
        Text(
            NSNumber(value: ellapsedTime),
            formatter: timeFormatter
        )
        .onChange(of: showSubSeconds) { _, newValue in
            timeFormatter.showSubSeconds = newValue
        }
    }
}

class EllapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    var showSubSeconds = true
    
    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval,
              let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }
        
        if showSubSeconds {
            let hundredths = Int(time.truncatingRemainder(dividingBy: 1) * 100)
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSeparator, hundredths)
        }
        
        return formattedString
    }
}

#Preview {
    EllaspsedTimeView()
}
