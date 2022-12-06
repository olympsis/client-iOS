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
    func fetchEvents(longitude: Double, latitude: Double, radius: Int, sport: String) async {
        do {
            let (data, resp) = try await eventService.getEvents(long: longitude, lat: latitude, radius: radius, sport: sport)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                await MainActor.run {
                    self.events = [Event]()
                    self.eventsCount = 0
                }
                return
            }
            let object = try decoder.decode(EventsResponse.self, from: data)
            await MainActor.run { // TODO: Check later about threads
                self.events = object.events
                self.eventsCount = object.totalEvents
            }
        } catch (let err) {
            print(err)
        }
    }
    
    func createEvent(dao: EventDao) async -> Bool {
        do {
            let res = try await eventService.createEvent(dao: dao)
            guard (res as? HTTPURLResponse)?.statusCode == 201 else {
                return false
            }
            return true
        } catch {
            print(error)
        }
        return false
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
    
    func addParticipant(id: String, dao: ParticipantDao) async -> AddParticipantResponse? {
        do {
            let (data,res) = try await eventService.addParticipant(id: id, dao: dao)
            guard (res as? HTTPURLResponse)?.statusCode == 200 else {
                return nil
            }
            let object = try decoder.decode(AddParticipantResponse.self, from: data)
            return object
        } catch {
            print(error)
        }
        return nil
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
