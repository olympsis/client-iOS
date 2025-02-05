//
//  EventsAnnotation.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct EventsAnnotation: View {
    
    var events: [Event]
    
    var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(self.heatMapGradient())
                        .frame(width: self.heatMapSize(in: geometry.size),
                               height: self.heatMapSize(in: geometry.size))
                        .opacity(self.heatMapOpacity())
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        
        private func heatMapSize(in size: CGSize) -> CGFloat {
            let baseSize: CGFloat = min(size.width, size.height) / 2
            let additionalSize: CGFloat = baseSize * CGFloat(events.count) / 10
            return baseSize + additionalSize
        }
        
        private func heatMapGradient() -> RadialGradient {
            let eventCount = events.count
            let colors: [Color] = {
                switch eventCount {
                case 0..<5:
                    return [Color.red.opacity(0.7), Color.yellow.opacity(0.3), Color.clear]
                case 5..<10:
                    return [Color.red.opacity(0.7), Color.orange.opacity(0.7), Color.orange.opacity(0.2), Color.clear]
                case 10..<20:
                    return [Color.red.opacity(1), Color.orange.opacity(0.7), Color.yellow.opacity(0.7), Color.yellow.opacity(0.2), Color.clear]
                default:
                    return [Color.red.opacity(1), Color.orange.opacity(1), Color.yellow.opacity(0.9), Color.yellow.opacity(0.2), Color.clear]
                }
            }()
            return RadialGradient(gradient: Gradient(colors: colors), center: .center, startRadius: 0, endRadius: heatMapSize(in: CGSize(width: 200, height: 200)) / 2)
        }
        
        private func heatMapOpacity() -> Double {
            let eventCount = events.count
            return min(0.2 + Double(eventCount) * 0.05, 1.0)
        }
}

#Preview {
    func gen() -> [Event] {
        func generateNearbyCoordinates(base: [Double], offset: Double) -> [Double] {
            let randomLatOffset = Double.random(in: -offset...offset)
            let randomLonOffset = Double.random(in: -offset...offset)
            return [base[0] + randomLonOffset, base[1] + randomLatOffset]
        }
        let initialVenue = VenueDescriptor(name: "Initial Venue", city: "City", state: "State", country: "Country", location: GeoJSON(type: "point", coordinates: [-122.008988, 37.334886]))
        // Generate 50 events
        var events: [Event] = []

        for i in 0..<50 {
            let newVenue = VenueDescriptor(
                name: "Venue \(i)",
                city: "City", state: "State", country: "Country",
                location: GeoJSON(type: "Point", coordinates: generateNearbyCoordinates(base: initialVenue.location!.coordinates, offset: 0.001))
            )
            
            let event = Event(
                id: UUID().uuidString,
                type: EVENT_TYPES.PickUp,
                poster: USER_SNIPPETS[0],
                organizers: [
                    Organizer(type: GROUP_TYPE.Club, id: CLUBS[0].id)
                ],
                venues: [i % 10 == 0 ? initialVenue : newVenue], // Add some events at the same venue
                imageURL: "soccer-\(i % 5)",
                title: "Pick Up Soccer International #\(i + 1)",
                body: "Let's go play boys!!!",
                sports: ["soccer"],
                level: EVENT_SKILL_LEVELS.All,
                startTime: 1699806600 + i * 3600, // Increment start time for each event
                actualStartTime: 1699806600 + i * 3600,
                stopTime: 1699806615 + i * 3600,
                actualStopTime: 0,
                maxParticipants: 10,
                participants: [
                    Participant(id: UUID().uuidString, user: USER_SNIPPETS[0], status: EVENT_RSVP_STATUS.Yes, createdAt: 1639364780)
                ],
                visibility: EVENT_VISIBILITY_TYPES.Public,
                createdAt: 1639364780,
                isSensitive: false
            )
            
            events.append(event)
        }
        return events
    }
    
    return EventsAnnotation(events: gen())
}
