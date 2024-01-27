//
//  NewEventManager.swift
//  Olympsis
//
//  Created by Joel on 1/21/24.
//

import os
import Foundation

class NewEventManager: ObservableObject {
    
    @Published var type: EVENT_TYPES
    @Published var title: String
    @Published var body: String
    @Published var externalLink: String
    
    @Published var field: Field?
    @Published var organizers: [GroupSelection]
    
    @Published var startDate: Date
    @Published var endDate: Date
    
    @Published var minParticipants: Double
    @Published var maxParticipants: Double
    
    @Published var sport: SPORT
    @Published var image: String?
    
    @Published var skillLevel: EVENT_SKILL_LEVELS = .All
    @Published var visibility: EVENT_VISIBILITY_TYPES = .Public
    
    private var logger: Logger = Logger(subsystem: "com.josephlabs.olympsis", category: "new_event_manager")
    
    
    init(type: EVENT_TYPES = .PickUp, title: String = "", body: String = "", externalLink: String = "", field: Field? = nil, organizers: [GroupSelection] = [GroupSelection](), startDate: Date = Date(), endDate: Date = Date().addingTimeInterval(30 * 60), minParticipants: Double = 0, maxParticipants: Double = 0, sport: SPORT = .soccer, image: String? = nil, skillLevel: EVENT_SKILL_LEVELS = .All, visibility: EVENT_VISIBILITY_TYPES = .Public) {
        self.type = type
        self.title = title
        self.body = body
        self.externalLink = externalLink
        self.field = field
        self.organizers = organizers
        self.startDate = startDate
        self.endDate = endDate
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.sport = sport
        self.image = image
        self.skillLevel = skillLevel
        self.visibility = visibility
    }
    
    convenience init(type: EVENT_TYPES = .PickUp) {
        self.init(type: type, title: "", body: "", externalLink: "", field: nil, organizers: [GroupSelection](), startDate: Date(), endDate: Date().addingTimeInterval(30 * 60), minParticipants: 0, maxParticipants: 0, sport: .soccer, image: nil, skillLevel: .All, visibility: .Public)
    }
    
    func GenerateOrganizers() -> [Organizer] {
        return self.organizers.map { o in
            switch (o.type) {
            case .Club:
                return Organizer(type: o.type.rawValue, id: o.club?.id ?? "")
            case .Organization:
                return Organizer(type: o.type.rawValue, id: o.organization?.id ?? "")
            }
        }
    }
    
    func GenerateFieldDescriptor() -> FieldDescriptor {
        if self.field?.description == "external" {
            return FieldDescriptor(type: FIELD_TYPES.External.rawValue, id: nil, name: field?.name, location: field?.location)
        } else {
            return FieldDescriptor(type: FIELD_TYPES.Internal.rawValue, id: field?.id, name: nil, location: nil)
        }
    }
    
    /**
        Return a data access object of an event to send through the API
     */
    func GenerateNewEventData() -> EventDao? {
        guard self.title != "",
              self.body != "",
              self.field != nil,
              self.organizers.count > 0,
              self.image != "" else {
            logger.error("failed to generate new event: invalid data")
            return nil
        }
        
        return EventDao(
            type: self.type.rawValue,
            organizers: self.GenerateOrganizers(),
            field: self.GenerateFieldDescriptor(),
            imageURL: self.image,
            title: self.title,
            body: self.body,
            sport: self.sport.rawValue,
            level: self.skillLevel.toInt(),
            startTime: Int(self.startDate.timeIntervalSince1970),
            stopTime: Int(self.endDate.timeIntervalSince1970),
            minParticipants: Int(self.minParticipants),
            maxParticipants: Int(self.maxParticipants),
            visibility: self.visibility.rawValue,
            externalLink: self.externalLink
        )
    }
    
    func GenerateNewEvent(id: String, dao: EventDao, user: UserData) -> Event? {
        guard let type = dao.type,
              let organizers = dao.organizers,
              let field = dao.field,
              let imageURL = dao.imageURL,
              let title = dao.title,
              let body = dao.body,
              let sport = dao.sport,
              let level = dao.level,
              let startTime = dao.startTime,
              let stopTime = dao.stopTime,
              let minParticipants = dao.minParticipants,
              let maxParticipants = dao.maxParticipants,
              let visibility = dao.visibility else {
            return nil
        }
        
        guard let uuid = user.uuid,
              let username = user.username else {
            return nil
        }
        
        let snippet = UserSnippet(uuid: uuid, username: username, imageURL: user.imageURL)
        let participant = Participant(id: UUID().uuidString, user: snippet, status: RSVP_STATUS.Going.rawValue, createdAt: 0)
        
        var clubs = [Club]()
        var orgs = [Organization]()
        self.organizers.forEach {
            if $0.type == .Club {
                if let c = $0.club {
                    clubs.append(c)
                }
            } else {
                if let o = $0.organization {
                    orgs.append(o)
                }
            }
        }
        
        return Event(
            id: id, 
            type: type,
            poster: snippet,
            organizers: organizers,
            field: field,
            imageURL: imageURL,
            title: title,
            body: body,
            sport: sport,
            level: level,
            startTime: startTime,
            stopTime: stopTime,
            minParticipants: minParticipants,
            maxParticipants: maxParticipants,
            participants: [participant],
            visibility: visibility,
            createdAt: Int(Date().timeIntervalSinceNow),
            externalLink: dao.externalLink != "" ? dao.externalLink : nil,
            clubs: clubs,
            organizations: orgs,
            fieldData: self.field
        )
    }
}
