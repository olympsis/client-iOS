//
//  CalendarEventEditView.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/2/25.
//

import UIKit
import SwiftUI
import EventKit
import EventKitUI

struct CalendarEventEditView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    var eventStore: EKEventStore
    var event: EKEvent?
    var onComplete: ((Bool) -> Void)?
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        
        if let event = event {
            controller.event = event
        } else {
            // Create a new event if none provided
            let newEvent = EKEvent(eventStore: eventStore)
            newEvent.startDate = Date()
            newEvent.endDate = Date().addingTimeInterval(3600) // 1 hour later
            newEvent.calendar = eventStore.defaultCalendarForNewEvents
            controller.event = newEvent
        }
        
        controller.editViewDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: CalendarEventEditView
        
        init(parent: CalendarEventEditView) {
            self.parent = parent
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            switch action {
            case .saved:
                // Event was saved
                parent.onComplete?(true)
            case .canceled:
                // Edit was canceled
                parent.onComplete?(false)
            case .deleted:
                // Event was deleted
                parent.onComplete?(false)
            @unknown default:
                parent.onComplete?(false)
            }
            
            parent.dismiss()
        }
    }
}

#Preview {
    CalendarEventEditView(eventStore: EKEventStore())
}
