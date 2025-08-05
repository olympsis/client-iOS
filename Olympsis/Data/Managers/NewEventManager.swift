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
    
    var type: EVENT_TYPES = .Regular
    
    var selectedTags: [Tag]
    var selectedSports: [Sport]
    
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
    var teamsConfig: TeamsConfig?
    var participantsConfig: ParticipantsConfig?
    
    var image: String?
    var tags: [Tag] = []
    var sports: [Sport] = []
    
    // More Options
    var config: EventConfig?
    var formatConfig: EventFormatConfig?
    var visibility: EVENT_VISIBILITY_TYPES = .Public
    
    var customVenueSearch: String = ""
    
    var recurrenceOptions: EventRecurrenceOptions?

    private var eventObserver = EventObserver()
    private var uploadObserver = UploadObserver()
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "new_event_manager")
    
    init(
        venues: [Venue] = [Venue](),
        organizers: [GroupSelection] = [GroupSelection]()
    ) {
        self.selectedTags = []
        self.selectedSports = []
        self.title = ""
        self.body = ""
        self.selectedVenues = venues
        self.organizers = organizers
        
        self.startDate = Date()
        self.endDate = Date().addingTimeInterval(60 * 60 * 24)
        
        self.externalLink = ""
        
        if venues.count > 0 {
            selectedVenueDescriptors = venues.map {
                return VenueDescriptor(id: $0.id, name: $0.name, city: $0.city, state: $0.state, country: $0.country)
            }
        }
    }
    
    func createEvent(user: User) async throws -> String? {
        guard let dto = generateEventDTO() else {
            throw NewEventError.invalidData
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
                throw MediaUploadError.unexpected("failed to get uploaded image url")
            }
            dto.event.mediaURL = url.replacingOccurrences(of: "olympsis-", with: "")
            
            guard let id = await eventObserver.createEvent(dao: dto) else {
                if let img = dto.event.mediaURL {
                    await deleteImage(image: img)
                }
                throw NewEventError.serverError(message: "Failed to create event.")
            }
            
            return id
        } else {
            guard let id = await eventObserver.createEvent(dao: dto) else {
                throw NewEventError.unknown(message: "Failed to create event.")
            }
            
            return id
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
              (self.selectedImageData != nil || self.image != ""),
              !self.selectedVenueDescriptors.isEmpty,
              self.organizers.count > 0 else {
            log.error("Failed to generate new event: invalid data")
            return nil
        }
        
        let event = EventDao(
            organizers: self.generateOrganizers(),
            venues: self.selectedVenueDescriptors,
            mediaURL: self.image,
            mediaType: .image,
            title: self.title,
            body: self.body,
            tags: self.selectedTags.map { $0.name },
            sports: self.selectedSports.map { $0.name.components(separatedBy: " ")[1] },
            config: self.config,
            formatConfig: self.formatConfig,
            startTime: self.startDate,
            stopTime: self.endDate,
            participantsConfig: self.participantsConfig,
            visibility: self.visibility,
            externalLink: self.externalLink.isEmpty ? nil : self.externalLink
        )
        
        return NewEventDao(event: event, includeHost: true, recurrence: recurrenceOptions)
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
