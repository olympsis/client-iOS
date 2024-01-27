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
    private let decoder = JSONDecoder()
    private let eventService = EventService()
    private let log = Logger(subsystem: "com.josephlabs.olympsis", category: "event_observer")
    
    /// Calls the field service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func location(longitude: Double, latitude: Double, radius: Int, sports: String, status: String="live") async -> LocationResponse? {
        do {
            let (data, resp) = try await eventService.location(long: longitude, lat: latitude, radius: radius, sports: sports, status: status)
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
    func fetchEvents(longitude: Double, latitude: Double, radius: Int, sports: String, status: String="live") async -> [Event]? {
        do {
            let (data, resp) = try await eventService.getEvents(long: longitude, lat: latitude, radius: radius, sports: sports, status: status)
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
    
    func createEvent(event: EventDao) async -> String? {
        do {
            let (data, resp) = try await eventService.createEvent(event: event)
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
    
    func deleteEvent(id: String) async -> Bool {
        do {
            let res = try await eventService.deleteEvent(id: id)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func addParticipant(id: String, _ participant: Participant) async -> Bool {
        do {
            let res = try await eventService.addParticipant(id: id, participant)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func removeParticipant(id: String, pid: String) async -> Bool {
        do {
            let res = try await eventService.removeParticipant(id: id, pid: pid)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func notifyParticipants(id: String, title: String, body: String) async -> Bool {
        do {
            let notif = Notification(title: title, body: body)
            let res = try await eventService.notifyParticipants(id: id, notif: notif)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
    
    func notifyClubMembers(id: String, title: String, body: String) async -> Bool {
        do {
            let notif = Notification(title: title, body: body)
            let res = try await eventService.notifyClubMembers(id: id, notif: notif)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            log.error("\(error)")
        }
        return false
    }
}
