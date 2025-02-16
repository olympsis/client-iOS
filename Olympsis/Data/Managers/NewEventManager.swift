//
//  NewEventManager.swift
//  Olympsis
//
//  Created by Joel on 1/21/24.
//

import os
import MapKit
import SwiftUI
import Foundation

@Observable
class NewEventManager {
    
    var type: EVENT_TYPES
    var title: String
    var body: String
    var externalLink: String
    var status: LOADING_STATE = .pending
    
    // Organizers
    var organizers: [GroupSelection]
    
    // Timestamps
    var startDate: Date
    var endDate: Date
    
    // Location
    var selectedVenues = [Venue]() {
        didSet {
            selectedVenueDescriptors = selectedVenues.map {
                if $0.description == "external" {
                    return VenueDescriptor(name: $0.name, city: $0.city, state: $0.state, country: $0.country, location: $0.location)
                } else {
                    return VenueDescriptor(id: $0.id, name: $0.name, city: $0.city, state: $0.state, country: $0.country)
                }
            }
        }
    }
    var selectedVenueDescriptors = [VenueDescriptor]()
    
    // Image
    var selectedImage: UIImage? {
        didSet {
            guard let image = selectedImage,
                  let data = image.jpegData(compressionQuality: 0.5) else {
                return
            }
            
            selectedImageData = data
        }
    }
    var selectedImageData: Data?
    var selectedImageIndex: Int = 0
    
    // Participants
    var minParticipants: Double
    var maxParticipants: Double
    
    // Sport
    var sport: SPORTS
    var image: String?
    
    // More Options
    var skillLevel: EVENT_SKILL_LEVELS = .All
    var visibility: EVENT_VISIBILITY_TYPES = .Public
    
    var customVenueSearch: String = ""
    
    var recurrenceOptions: EventRecurrenceOptions?
    
    private var eventObserver = EventObserver()
    private var uploadObserver = UploadObserver()
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "new_event_manager")
    
    
    init(
        type: EVENT_TYPES = .Regular,
        title: String = "",
        body: String = "",
        venues: [Venue] = [Venue](),
        organizers: [GroupSelection] = [GroupSelection](),
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(30 * 60),
        minParticipants: Double = 0,
        maxParticipants: Double = 0,
        sport: SPORTS = .soccer,
        image: String? = nil,
        skillLevel: EVENT_SKILL_LEVELS = .All,
        visibility: EVENT_VISIBILITY_TYPES = .Public,
        externalLink: String = ""
    ) {
        self.type = type
        self.title = title
        self.body = body
        self.selectedVenues = venues
        self.organizers = organizers
        self.startDate = startDate
        self.endDate = endDate
        self.minParticipants = minParticipants
        self.maxParticipants = maxParticipants
        self.sport = sport
        self.image = sport.images().first
        self.skillLevel = skillLevel
        self.visibility = visibility
        self.externalLink = externalLink
        
        if venues.count > 0 {
            selectedVenueDescriptors = venues.map {
                return VenueDescriptor(id: $0.id, name: $0.name, city: $0.city, state: $0.state, country: $0.country)
            }
        }
    }
    
    convenience init(type: EVENT_TYPES = .Regular) {
        self.init(
            type: type, 
            title: "",
            body: "",
            venues: [Venue](),
            organizers: [GroupSelection](),
            startDate: Date(),
            endDate: Date().addingTimeInterval(30 * 60),
            minParticipants: 0,
            maxParticipants: 0,
            sport: .soccer,
            image: SPORTS.soccer.images().first,
            skillLevel: .All,
            visibility: .Public,
            externalLink: ""
        )
    }
    
    func createEvent(user: UserData) async throws -> Event? {
        guard let dto = generateEventDTO() else {
            return nil
        }
        
        if let data = selectedImageData {
            guard let resp = await uploadImage(data: data) else {
                return nil
            }
            if resp.score > 4 {
                status = .pending
                throw MediaUploadError.innapropriateContent
            }
            if resp.score > 3 {
                dto.event.isSensitive = true
            }
            
            guard let url = resp.url else {
                status = .pending
                return nil
            }
            dto.event.imageURL = url.replacingOccurrences(of: "olympsis-", with: "")
            
            guard let id = await eventObserver.createEvent(dao: dto) else {
                if let img = dto.event.imageURL {
                    await deleteImage(image: img)
                }
                return nil
            }
            
            return generateNewEvent(id: id, dao: dto.event, user: user)
        } else {
            guard let id = await eventObserver.createEvent(dao: dto) else {
                if let img = dto.event.imageURL {
                    await deleteImage(image: img)
                }
                return nil
            }
            
            return generateNewEvent(id: id, dao: dto.event, user: user)
        }
    }
    
    /// Generates the organizers of the event
    ///
    /// This function takes the organizers that we have and assign the club or the organization associated with it
    ///
    /// - Returns: `[Organizer]` an array of the organizers
    func generateOrganizers() -> [Organizer] {
        return self.organizers.map { o in
            switch (o.type) {
            case .Club:
                return Organizer(type: o.type, id: o.club?.id ?? "")
            case .Organization:
                return Organizer(type: o.type, id: o.organization?.id ?? "")
            }
        }
    }
    
    /// Removes a venue from the list at the specified offset
    ///
    /// This function enables our swipe to delete feature in our venue picker
    ///
    /// - Parameter offsets: The offset of which to remove a venue from
    func deleteVenues(at offsets: IndexSet) {
        selectedVenues.remove(atOffsets: offsets)
    }
    
    /// Generates a data transfer object so that we can let the backend know that we have a new event
    ///
    /// We do some checking to make sure that we have certain data in the first place before generating this object.
    /// We want the data to be complete before we attempt to make a request to the server
    ///
    /// - Returns: an optional `EventDao` object
    func generateEventDTO() -> NewEventDao? {
        guard !self.title.isEmpty,
              !self.body.isEmpty,
              !self.selectedVenueDescriptors.isEmpty,
              self.organizers.count > 0 else {
            log.error("Failed to generate new event: invalid data")
            return nil
        }
        
        let event = EventDao(
            type: self.type,
            organizers: self.generateOrganizers(),
            venues: self.selectedVenueDescriptors,
            imageURL: self.image,
            title: self.title,
            body: self.body,
            sports: [self.sport.rawValue],
            level: self.skillLevel,
            startTime: Int(self.startDate.timeIntervalSince1970),
            stopTime: Int(self.endDate.timeIntervalSince1970),
            minParticipants: Int(self.minParticipants),
            maxParticipants: Int(self.maxParticipants),
            visibility: self.visibility,
            isSensitive: false,
            externalLink: self.externalLink.isEmpty ? nil : self.externalLink
        )
        
        return NewEventDao(event: event, includeHost: true, recurrence: recurrenceOptions)
    }
    
    /// Generates a new event object
    ///
    /// This function creates a new event object locally so that the user can see their event immediately after it's been created
    ///
    /// - Parameter id: The string identifier of the newly created event
    /// - Parameter dto: The DTO object that was used to create the event
    /// - Parameter user: The user's information to add in a new participant
    ///
    /// - Returns:  An optional `Event` object
    func generateNewEvent(id: String, dao: EventDao, user: UserData) -> Event? {
        guard let type = dao.type,
              let organizers = dao.organizers,
              let venues = dao.venues,
              let imageURL = dao.imageURL,
              let title = dao.title,
              let body = dao.body,
              let sports = dao.sports,
              let level = dao.level,
              let startTime = dao.startTime,
              let stopTime = dao.stopTime,
              let minParticipants = dao.minParticipants,
              let maxParticipants = dao.maxParticipants,
              let visibility = dao.visibility,
              let sensitivity = dao.isSensitive else {
            log.error("Failed to validate dto data for new event")
            return nil
        }
        
        guard let uuid = user.uuid,
              let username = user.username else {
            return nil
        }
        
        let snippet = UserSnippet(uuid: uuid, username: username, imageURL: user.imageURL)
        let participant = Participant(id: UUID().uuidString, user: snippet, status: EVENT_RSVP_STATUS.Yes, createdAt: Int(Date.now.timeIntervalSince1970))
        
        return Event(
            id: id, 
            type: type,
            poster: snippet,
            organizers: organizers,
            venues: venues,
            imageURL: imageURL,
            title: title,
            body: body,
            sports: sports,
            level: level,
            startTime: startTime,
            stopTime: stopTime,
            minParticipants: minParticipants,
            maxParticipants: maxParticipants,
            participants: [participant],
            visibility: visibility,
            createdAt: Int(Date().timeIntervalSince1970), 
            isSensitive: sensitivity,
            externalLink: dao.externalLink != "" ? dao.externalLink : nil
        )
    }
    
    /// Handles uploading an image to a bucket
    ///
    /// This function is meant to upload and recieve the response of the uploaded object.
    /// That way we can handle potential harmful images
    ///
    /// - Parameter data: The data of the image to be uploaded
    ///
    /// - Returns: an optional `ImageUploadResponse`
    func uploadImage(data: Data?) async -> ImageUploadResponse? {
        // image unique id
        let imageId = UUID().uuidString
        
        guard let d = data else {
            log.error("Failed to find image data: \(imageId)")
            return nil
        }
        
        guard let response = await uploadObserver.UploadImage(location: "/olympsis-event-images", fileName: imageId, data: d) else {
            log.error("Failed to upload image: \(imageId)")
            return nil
        }
        return response
    }
    
    /// Handles deleting an image from a bucket
    /// - Parameters image: The string of the image's url
    func deleteImage(image: String) async {
        let resp = await uploadObserver.DeleteObject(path: "/olympsis-event-images", name: GrabImageIdFromURL(image))
        if !resp {
            log.error("Failed to delete image: \(image)")
        }
    }
}
