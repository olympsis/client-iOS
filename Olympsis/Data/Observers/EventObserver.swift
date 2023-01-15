//
//  EventObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Foundation

/// Field Observer is a class object that keeps tracks of and fetches fields
class EventObserver: ObservableObject{
    private let decoder: JSONDecoder
    private let eventService: EventService
    
    @Published var isLoading = true
    @Published var eventsCount = 0
    @Published var events = [Event]()
    
    init(){
        decoder = JSONDecoder()
        eventService = EventService()
    }
    
    /// Calls the field service to get fields based on certain params
    /// - Parameter location: `[String]` latitude, longitude
    /// - Parameter descritiveLocation: `[String]` city, state, country
    func fetchEvents(longitude: Double, latitude: Double, radius: Int, sport: String) async -> [Event]? {
        do {
            let (data, resp) = try await eventService.getEvents(long: longitude, lat: latitude, radius: radius, sport: sport)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(EventsResponse.self, from: data)
            return object.events
        } catch {
            print(error)
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
            print(error)
        }
        return nil
    }
    
    func createEvent(dao: EventDao) async -> Event? {
        do {
            let (data,resp) = try await eventService.createEvent(dao: dao)
            guard (resp as? HTTPURLResponse)?.statusCode == 201 else {
                return nil
            }
            let obj = try decoder.decode(Event.self, from: data)
            return obj
        } catch {
            print(error)
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
            print(error)
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
            print(error)
        }
        return false
    }
    
    func addParticipant(id: String, dao: ParticipantDao) async -> Bool {
        do {
            let res = try await eventService.addParticipant(id: id, dao: dao)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return false
            }
            return true
        } catch {
            print(error)
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
            print(error)
        }
        return false
    }
}
