//
//  EventObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import os
import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class EventObserver: ObservableObject{
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    private let eventService = EventService()
    private let log = Logger(subsystem: "com.olympsis.client", category: "event_observer")
    
    /// Calls the field service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func location(longitude: Double, latitude: Double, radius: Int, sports: String, status: String="live") async -> LocationResponse? {
        do {
            let (data, resp) = try await eventService.location(long: longitude, lat: latitude, radius: radius, sports: sports, status: status, limit: 100)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(LocationResponse.self, from: data)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    /// Calls the field service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func fetchEvents(longitude: Double, latitude: Double, radius: Double, tags:String? = nil, sports: String? = nil, status: String = "live", skip: Int = 0, limit: Int = 100) async -> [Event]? {
        do {
            let (data, resp) = try await eventService.getEvents(long: longitude, lat: latitude, radius: radius, tags: tags, sports: sports, status: status, skip: skip, limit: limit)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                if (resp as? HTTPURLResponse)?.statusCode == 204 {
                    return []
                }
                return nil
            }
            let object = try decoder.decode(EventsResponse.self, from: data)
            return object.events
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func fetchEventsByFieldID(_ id: String) async -> [Event]? {
        do {
            let (data, resp) = try await eventService.getEventsByField(id: id)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(EventsResponse.self, from: data)
            return object.events
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func fetchEvent(id: String) async -> Event? {
        do {
            let (data, resp) = try await eventService.getEvent(id: id)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(Event.self, from: data)
            return object
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func getUserPastEvents(userID: String) async -> [Event] {
        do {
            let (data, resp) = try await eventService.getUserPastEvents(userID: userID)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return []
            }
            let object = try decoder.decode([Event].self, from: data)
            return object
        } catch {
            log.error("\(error)")
            return []
        }
    }
    
    func createEvent(dao: NewEventDao) async -> String? {
        do {
            let (data, resp) = try await eventService.createEvent(dao: dao)
            guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
                return nil
            }
            let object = try decoder.decode(CreateResponse.self, from: data)
            return object.id
        } catch {
            log.error("\(error)")
        }
        return nil
    }
    
    func updateEvent(id: String, dao: EventDao) async -> Bool {
        do {
            let res = try await eventService.updateEvent(id: id, dao: dao)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func deleteEvent(id: String, deleteAll: Bool = false) async -> Bool {
        do {
            let res = try await eventService.deleteEvent(id: id, deleteAll: deleteAll)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    // MARK: - Participants
    
    func addParticipant(id: String, dao: ParticipantDao) async throws -> String {
        do {
            let (data, resp) = try await eventService.addParticipant(id: id, dao: dao)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
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
    
    func removeParticipant(id: String, pid: String?=nil) async -> Bool {
        do {
            let res = try await eventService.removeParticipant(id: id, pid: pid)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to remove participant: \(error)")
        }
        return false
    }
    
    // MARK: - Comments
    
    func addComment(id: String, _ comment: EventCommentDao) async throws -> String {
        do {
            let (data, resp) = try await eventService.addComment(id: id, comment)
            guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
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
        do {
            let res = try await eventService.removeComment(id: id, cid: cid)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to remove comment: \(error)")
        }
        return false
    }
    
    // MARK: - Notifications
    
    func notifyParticipants(id: String, title: String, body: String) async -> Bool {
        do {
            let notif = OlympsisNotification(title: title, body: body)
            let res = try await eventService.notifyParticipants(id: id, notif: notif)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to notify participants: \(error)")
        }
        return false
    }
    
    func notifyClubMembers(id: String, title: String, body: String) async -> Bool {
        do {
            let notif = OlympsisNotification(title: title, body: body)
            let res = try await eventService.notifyClubMembers(id: id, notif: notif)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("Failed to notify club members: \(error)")
        }
        return false
    }
}
