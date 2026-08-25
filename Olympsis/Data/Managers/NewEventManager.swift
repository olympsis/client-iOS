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
    var validationStatus: NEW_EVENT_ERROR?
    
    var selectedTags: [Tag]
    var selectedSports: [Sport]
    
    var title: String
    var body: String
    var externalLinks: [EventLink]
    var status: LOADING_STATE = .pending
    
    // Organizers
    var poster: UserSnippet?
    var organizers: [GroupSelection]
    var sponsors: [Sponsor]

    // Invitees — users selected to be invited to the event. We hold full
    // `UserSnippet`s here so the UI can render names/avatars; on submission we
    // map these down to their user IDs for `NewEventDao.invitees`.
    var invitees: [UserSnippet]

    // Timestamps
    var startDate: Date
    var endDate: Date
    
    var startDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy - hh:mm a"
        return dateFormatter.string(from: startDate)
    }
    
    var endDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy - hh:mm a"
        return dateFormatter.string(from: endDate)
    }

    // Date-only string for the time card pills (e.g. "Jun 30, 2026")
    var startDayString: String { NewEventManager.dayFormatter.string(from: startDate) }
    var endDayString: String { NewEventManager.dayFormatter.string(from: endDate) }

    // Time-only string for the time card pills (e.g. "7:00 PM")
    var startTimeString: String { NewEventManager.timeFormatter.string(from: startDate) }
    var endTimeString: String { NewEventManager.timeFormatter.string(from: endDate) }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    // Location(s)
    var selectedVenues = [Venue]()
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
    
    // MARK: - Geocode Cache
    
    /// Cached geocode results keyed by coordinate string (lat/lon rounded to 4 dp ≈ 11m).
    /// Persists for the lifetime of the event creation flow and is explicitly cleared on exit.
    struct GeocodeResult {
        let city: String
        let state: String
        let country: String
        let fullAddress: String?
    }
    var geocodeCache: [String: GeocodeResult] = [:]
    
    /// Returns a stable cache key for a coordinate pair, rounded to ~11m precision.
    func geocodeCacheKey(lat: Double, lon: Double) -> String {
        String(format: "%.4f_%.4f", lat, lon)
    }
    
    /// Clears the geocode cache. Call this when the user exits the new event flow.
    func clearGeocodeCache() {
        geocodeCache.removeAll()
    }

    private var eventService = EventService()
    private var uploadService = UploadService()
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
        self.sponsors = []
        self.invitees = []
        
        self.startDate = Date()
        self.endDate = Date().addingTimeInterval(60 * 60 * 24)
        
        self.externalLinks = []
        
        if venues.count > 0 {
            selectedVenueDescriptors = venues.map {
                return VenueDescriptor(id: $0.id, name: $0.name, city: $0.city, state: $0.state, country: $0.country)
            }
        }
    }
    
    /// Handles adding a new venue to the manager
    /// - Parameters venue: the venue we are adding to the manager
    func addVenueDescriptor(_ venue: Venue) {
        let descriptor = VenueDescriptor(
            id: venue.description == "external" ? nil : venue.id,
            name: venue.name,
            city: venue.city,
            state: venue.state,
            country: venue.country,
            location: venue.location,
            fullAddress: venue.fullAddress
        )
        
        selectedVenues.append(venue)
        selectedVenueDescriptors.append(descriptor)
    }
    
    /// Handles removing a venue descriptor from the manager
    /// - Parameters venue: the venue we are removing from the manager
    func removeVenueDescriptor(_ descriptor: VenueDescriptor) {
        selectedVenueDescriptors.removeAll(where: { $0.name == descriptor.name })
        selectedVenues.removeAll(where: { $0.name == descriptor.name })
    }
    
    /// Validates the new event view
    ///
    /// This function makes sure that we have the right data populated.
    /// If we are missing some data we want to scroll the user down to where they need add more information
    ///
    /// - Parameter value: The scroll view proxy needed to scroll the user down to the specific location
    ///
    /// - Returns an optional `NEW_EVENT_ERROR` to let us know what went wrong
    func validateEvent(value: ScrollViewProxy) -> NEW_EVENT_ERROR? {
        // make sure we have a title
        guard !title.isEmpty else {
            Task { @MainActor in
                validationStatus = .noTitle
                withAnimation {
                    value.scrollTo(1)
                }
            }
            return .noTitle
        }
        
        // make sure end date is greater than start
        guard endDate > startDate else {
            Task { @MainActor in
                validationStatus = .unexpected
                withAnimation {
                    value.scrollTo(3)
                }
            }
            return .unexpected
        }
        
        // make sure we have a description
        guard !body.isEmpty else {
            Task { @MainActor in
                validationStatus = .noDescription
                withAnimation {
                    value.scrollTo(4)
                }
            }
            return .noDescription
        }
        
        // make sure we have selected venues
        guard !selectedVenueDescriptors.isEmpty else {
            Task { @MainActor in
                validationStatus = .noSelectedField
                withAnimation {
                    value.scrollTo(5)
                }
            }
            return .noSelectedField
        }
        
        return nil
    }
    
    /// Triggers the create event action
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
            
            guard let id = await eventService.createEvent(dao: dto) else {
                if let img = dto.event.mediaURL {
                    await deleteImage(image: img)
                }
                throw NewEventError.serverError(message: "Failed to create event.")
            }
            
            return id
        } else {
            guard let id = await eventService.createEvent(dao: dto) else {
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
              !self.selectedVenueDescriptors.isEmpty else {
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
            // Split on space to extract the sport identifier (e.g. "Sport Basketball" → "Basketball").
            // Falls back to the full name if there's no space, avoiding an index out-of-bounds crash.
            sports: self.selectedSports.map { sport in
                let parts = sport.name.components(separatedBy: " ")
                return parts.count > 1 ? parts[1] : sport.name
            },
            config: self.config,
            formatConfig: self.formatConfig,
            startTime: self.startDate,
            stopTime: self.endDate,
            participantsConfig: self.participantsConfig,
            teamsConfig: self.teamsConfig,
            visibility: self.visibility,
            externalLinks: self.externalLinks.isEmpty ? nil : self.externalLinks
        )
        
        // Map selected invitee snippets down to their user IDs for the DTO.
        let inviteeIDs = self.invitees.compactMap { $0.userID }

        return NewEventDao(event: event, includeHost: true, invitees: inviteeIDs, recurrence: recurrenceOptions)
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
        
        guard let response = await uploadService.UploadImage(location: "/olympsis-event-images", fileName: imageId, data: d) else {
            log.error("Failed to upload image: \(imageId)")
            return nil
        }
        return response
    }
    
    /// Handles deleting an image from a bucket
    /// - Parameters image: The string of the image's url
    func deleteImage(image: String) async {
        let resp = await uploadService.DeleteObject(path: "/olympsis-event-images", name: GrabImageIdFromURL(image))
        if !resp {
            log.error("Failed to delete image: \(image)")
        }
    }
}
