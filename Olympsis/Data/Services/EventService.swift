//
//  EventService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
import Hermes
import SwiftUI
import Foundation

class EventService: APIService {

    let http: Courrier
    let decoder: JSONDecoder
    private let log = Logger(subsystem: "com.olympsis.client", category: "event_service")

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
        // Server encodes event timestamps as ISO8601 — must match across every decode below.
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        self.decoder = d
    }

    /// Calls the field service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func location(longitude: Double, latitude: Double, radius: Int, sports: String, status: String = "live") async -> LocationResponse? {
        let endpoint = Endpoint("/v1/events/location", queryItems: [
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: sports),
            URLQueryItem(name: "status", value: status),
            URLQueryItem(name: "limit", value: String(100)),
        ])

        do {
            return try await request(.GET, endpoint)
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    /// Calls the field service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func fetchEvents(longitude: Double, latitude: Double, radius: Double, tags: String? = nil, sports: String? = nil, status: String = "live", skip: Int = 0, limit: Int = 100) async -> [Event]? {
        var queries = [
            URLQueryItem(name: "location", value: "\(longitude),\(latitude)"),
            URLQueryItem(name: "radius", value: String(radius)),
        ]

        if (tags != nil && !tags!.isEmpty) {
            queries.append(URLQueryItem(name: "tags", value: tags))
        }

        if (sports != nil && !sports!.isEmpty) {
            queries.append(URLQueryItem(name: "sports", value: sports))
        }

        queries.append(URLQueryItem(name: "status", value: status))
        queries.append(URLQueryItem(name: "skip", value: String(0)))
        queries.append(URLQueryItem(name: "limit", value: String(limit)))

        let endpoint = Endpoint("/v1/events", queryItems: queries)
        do {
            // 204 means no results in range — an empty list, not a failure.
            let (data, statusCode) = try await requestRaw(.GET, endpoint)
            guard statusCode == 200 else {
                return statusCode == 204 ? [] : nil
            }
            let object = try decoder.decode(EventsResponse.self, from: data)
            return object.events
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    func fetchPastEvents(skip: Int = 0, limit: Int = 100) async -> [Event] {
        let queries = [
            URLQueryItem(name: "status", value: "ended"),
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit)),
        ]

        let endpoint = Endpoint("/v1/events", queryItems: queries)
        do {
            let (data, statusCode) = try await requestRaw(.GET, endpoint)
            guard statusCode == 200 else {
                return []
            }
            let object = try decoder.decode(EventsResponse.self, from: data)
            return object.events
        } catch {
            log.error("\(error)")
        }
        return []
    }

    func fetchEventsByVenueID(_ id: String) async -> [Event]? {
        let endpoint = Endpoint("/v1/events/venue/\(id)")
        do {
            let object: EventsResponse = try await request(.GET, endpoint)
            return object.events
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    func fetchEvent(id: String) async -> Event? {
        let endpoint = Endpoint("/v1/events/\(id)", queryItems: [URLQueryItem]())
        do {
            return try await request(.GET, endpoint)
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    func getUserPastEvents(userID: String) async -> [Event] {
        let endpoint = Endpoint("/v1/events/past/user/\(userID)", queryItems: [URLQueryItem]())
        do {
            return try await request(.GET, endpoint)
        } catch {
            log.error("\(error)")
            return []
        }
    }

    func createEvent(dao: NewEventDao) async -> String? {
        let endpoint = Endpoint("/v1/events")
        do {
            let object: CreateResponse = try await request(.POST, endpoint, body: EncodeToData(dao), expecting: 201)
            return object.id
        } catch {
            log.error("\(error)")
        }
        return nil
    }

    func updateEvent(id: String, dao: EventDao) async -> Bool {
        let endpoint = Endpoint("/v1/events/\(id)", queryItems: [URLQueryItem]())
        do {
            let (_, statusCode) = try await requestRaw(.PUT, endpoint, body: EncodeToData(dao))
            return statusCode == 200
        } catch {
            log.error("\(error)")
        }
        return false
    }

    func deleteEvent(id: String, deleteAll: Bool = false) async -> Bool {
        let endpoint = Endpoint("/v1/events/\(id)", queryItems: deleteAll ? [URLQueryItem(name: "deleteAll", value: "true")] : [])
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, endpoint)
            return statusCode == 200
        } catch {
            log.error("\(error)")
        }
        return false
    }

    // MARK: - Participants

    func addParticipant(id: String, dao: ParticipantDao) async throws -> String {
        let endpoint = Endpoint("/v1/events/\(id)/participants", queryItems: [URLQueryItem]())
        do {
            let (data, statusCode) = try await requestRaw(.POST, endpoint, body: EncodeToData(dao))
            guard statusCode == 200 else {
                throw EventError.failedToAddParticipant
            }

            let object = try decoder.decode(CreateResponse.self, from: data)
            guard let id = object.id else {
                throw EventError.failedToAddParticipant
            }

            return id
        } catch {
            log.error("Failed to add participant: \(error)")
            throw EventError.failedToAddParticipant
        }
    }

    func removeParticipant(id: String, pid: String? = nil) async -> Bool {
        let endpoint: Endpoint
        if (pid != nil && pid != "") {
            endpoint = Endpoint("/v1/events/\(id)/participants/\(pid!)", queryItems: [URLQueryItem]())
        } else {
            endpoint = Endpoint("/v1/events/\(id)/participants", queryItems: [URLQueryItem]())
        }

        do {
            let (_, statusCode) = try await requestRaw(.DELETE, endpoint)
            return statusCode == 200
        } catch {
            log.error("Failed to remove participant: \(error)")
        }
        return false
    }

    // MARK: - Comments

    func addComment(id: String, _ comment: EventCommentDao) async throws -> String {
        let endpoint = Endpoint("/v1/events/\(id)/comments", queryItems: [URLQueryItem]())
        do {
            let (data, statusCode) = try await requestRaw(.POST, endpoint, body: EncodeToData(comment))
            guard statusCode == 201 else {
                throw EventError.failedToAddComment
            }

            let object = try decoder.decode(CreateResponse.self, from: data)
            guard let id = object.id else {
                throw EventError.failedToAddComment
            }

            return id
        } catch {
            log.error("Failed to add comment: \(error)")
            throw EventError.failedToAddComment
        }
    }

    func removeComment(id: String, cid: String) async -> Bool {
        let endpoint = Endpoint("/v1/events/\(id)/comments/\(cid)", queryItems: [URLQueryItem]())
        do {
            let (_, statusCode) = try await requestRaw(.DELETE, endpoint)
            return statusCode == 200
        } catch {
            log.error("Failed to remove comment: \(error)")
        }
        return false
    }

    // MARK: - Notifications

    func notifyParticipants(id: String, title: String, body: String) async -> Bool {
        let notif = OlympsisNotification(title: title, body: body)
        let endpoint = Endpoint("/v1/events/\(id)/notify/participants", queryItems: [URLQueryItem]())
        do {
            let (_, statusCode) = try await requestRaw(.POST, endpoint, body: EncodeToData(notif))
            return statusCode == 200
        } catch {
            log.error("Failed to notify participants: \(error)")
        }
        return false
    }

    func notifyClubMembers(id: String, title: String, body: String) async -> Bool {
        let notif = OlympsisNotification(title: title, body: body)
        let endpoint = Endpoint("/v1/events/\(id)/notify/club", queryItems: [URLQueryItem]())
        do {
            let (_, statusCode) = try await requestRaw(.POST, endpoint, body: EncodeToData(notif))
            return statusCode == 200
        } catch {
            log.error("Failed to notify club members: \(error)")
        }
        return false
    }
}
