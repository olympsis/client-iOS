//
//  EventService.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Hermes
import SwiftUI
import Foundation

class EventService {

    private var http: Courrier

    init() {
        let env = AppEnvironment.current
        self.http = Courrier(env.useHTTPS ? .HTTPS : .HTTP, host: env.apiHost)
    }

    func location(long: Double, lat: Double, radius: Int, sports: String, status: String, limit: Int) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/events/location", queryItems: [
            URLQueryItem(name: "longitude", value: String(long)),
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "radius", value: String(radius)),
            URLQueryItem(name: "sports", value: sports),
            URLQueryItem(name: "status", value: status),
            URLQueryItem(name: "limit", value: String(limit)),
        ])

        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func getEvents(long: Double, lat: Double, radius: Double, tags: String? = nil, sports: String? = nil, status: String, skip: Int, limit: Int) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()

        var queries = [
            URLQueryItem(name: "location", value: "\(long),\(lat)"),
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

        let endpoint = Hermes.Endpoint("/v1/events", queryItems: queries)
        return try await http.Request(.GET, endpoint, headers: headers)
    }
    
    func getPastEvents(skip: Int, limit: Int) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()

        var queries = [
            URLQueryItem(name: "status", value: "ended"),
        ]

        queries.append(URLQueryItem(name: "skip", value: String(skip)))
        queries.append(URLQueryItem(name: "limit", value: String(limit)))

        let endpoint = Hermes.Endpoint("/v1/events", queryItems: queries)
        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func getEventsByVenue(id: String) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Hermes.Endpoint("/v1/events/venue/\(id)")

        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func getEvent(id: String) async throws -> (Data, URLResponse){
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)", queryItems: [URLQueryItem]())

        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func getUserPastEvents(userID: String) async throws -> (Data, URLResponse){
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/past/user/\(userID)", queryItems: [URLQueryItem]())

        return try await http.Request(.GET, endpoint, headers: headers)
    }

    func createEvent(dao: NewEventDao) async throws -> (Data,URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events")
        return try await http.Request(.POST, endpoint, body: EncodeToData(dao), headers: headers)
    }

    func updateEvent(id: String, dao: EventDao) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)", queryItems: [URLQueryItem]())

        let (_, resp) = try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: headers)
        return resp
    }

    func deleteEvent(id: String, deleteAll: Bool = false) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)", queryItems: deleteAll ? [URLQueryItem(name: "deleteAll", value: "true")] : [])

        let (_, resp) = try await http.Request(.DELETE, endpoint, headers: headers)
        return resp
    }

    // MARK: - Participants

    func addParticipant(id: String, dao: ParticipantDao) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)/participants", queryItems: [URLQueryItem]())

        return try await http.Request(.POST, endpoint, body: EncodeToData(dao), headers: headers)
    }

    func removeParticipant(id: String, pid: String?=nil) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        if ((pid) != nil && pid != "") {
            let endpoint = Endpoint("/v1/events/\(id)/participants/\(pid!)", queryItems: [URLQueryItem]())

            let (_, resp) = try await http.Request(.DELETE, endpoint,  headers: headers)
            return resp
        } else {
            let endpoint = Endpoint("/v1/events/\(id)/participants", queryItems: [URLQueryItem]())

            let (_, resp) = try await http.Request(.DELETE, endpoint,  headers: headers)
            return resp
        }
    }

    // MARK: - Comments

    func addComment(id: String, _ comment: EventCommentDao) async throws -> (Data, URLResponse) {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)/comments", queryItems: [URLQueryItem]())

        return try await http.Request(.POST, endpoint, body: EncodeToData(comment), headers: headers)
    }

    func removeComment(id: String, cid: String) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)/comments/\(cid)", queryItems: [URLQueryItem]())

        let (_, resp) = try await http.Request(.DELETE, endpoint,  headers: headers)
        return resp
    }

    // MARK: - Notifications

    func notifyParticipants(id: String, notif: OlympsisNotification) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)/notify/participants", queryItems: [URLQueryItem]())

        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(notif), headers: headers)
        return resp
    }

    func notifyClubMembers(id: String, notif: OlympsisNotification) async throws -> URLResponse {
        let headers = try await AppEnvironment.authHeaders()
        let endpoint = Endpoint("/v1/events/\(id)/notify/club", queryItems: [URLQueryItem]())

        let (_, resp) = try await http.Request(.POST, endpoint, body: EncodeToData(notif), headers: headers)
        return resp
    }
}
