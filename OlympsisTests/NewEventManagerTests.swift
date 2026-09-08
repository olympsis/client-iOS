//
//  NewEventManagerTests.swift
//  OlympsisTests
//
//  Created by Joel Joseph on 8/5/25.
//

import Testing
import Foundation
@testable import Olympsis

// MARK: - Event Config
struct NewEventConfigTests {
    
    let manager = NewEventManager()
    
    // Set up basic data needed to be able to generate a dto
    init() {
        manager.title = "Test event title"
        manager.body = "Test event body"
        manager.image = "test-image-url"
        manager.sports = [Sport(name: "soccer", images: [])]
        manager.organizers = [GroupSelection(type: .Club)]
        manager.selectedVenueDescriptors = [VenueDescriptor(name: "test-venue", city: "test-city", state: "test-state", country: "test-country")]
    }
    
    @Test
    func testHidePosterConfig() {
        manager.config = .init(hidePoster: true)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["config"] as? [String: Any]

            #expect(((config?["hide_poster"]) != nil) == true)
            #expect(config?["hide_location"] == nil)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testHideLocationConfig() {
        manager.config = .init(hideLocation: true)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["config"] as? [String: Any]

            #expect(config?["hide_poster"] == nil)
            #expect(((config?["hide_location"]) != nil) == true)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testFullConfig() {
        manager.config = .init(hidePoster: true, hideLocation: true)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["config"] as? [String: Any]

            #expect(((config?["hide_poster"]) != nil) == true)
            #expect(((config?["hide_location"]) != nil) == true)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
}

// MARK: - Event Format Confif
struct NewEventFormatConfigTests {
    let manager = NewEventManager()
    
    // Set up basic data needed to be able to generate a dto
    init() {
        manager.title = "Test event title"
        manager.body = "Test event body"
        manager.image = "test-image-url"
        manager.sports = [Sport(name: "soccer", images: [])]
        manager.organizers = [GroupSelection(type: .Club)]
        manager.selectedVenueDescriptors = [VenueDescriptor(name: "test-venue", city: "test-city", state: "test-state", country: "test-country")]
    }
    
    @Test
    func testEventFormats() {
        manager.formatConfig = .init(formats: [.versus5, .winnerStaysOn])
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["format_config"] as? [String: Any]
            let formats = config?["formats"] as? [String]
            
            #expect(formats?[0] == "5v5")
            #expect(formats?[1] == "winner_stays_on")
        } catch {
            Issue.record("Failed to parse json")
        }
    }
}

// MARK: - Participants Config
struct NewEventParticipantsConfigTests {
    let manager = NewEventManager()
    
    // Set up basic data needed to be able to generate a dto
    init() {
        manager.title = "Test event title"
        manager.body = "Test event body"
        manager.image = "test-image-url"
        manager.sports = [Sport(name: "soccer", images: [])]
        manager.organizers = [GroupSelection(type: .Club)]
        manager.selectedVenueDescriptors = [VenueDescriptor(name: "test-venue", city: "test-city", state: "test-state", country: "test-country")]
    }
    
    @Test
    func testHasWaitlist() {
        manager.participantsConfig = .init(hasWaitlist: true)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["participants_config"] as? [String: Any]

            #expect(config?["has_waitlist"] as! Bool == true)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testHideParticipants() {
        manager.participantsConfig = .init(hideParticipants: true)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["participants_config"] as? [String: Any]

            #expect(config?["hide_participants"] as! Bool == true)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testMinMaxParticipants() {
        manager.participantsConfig = .init(minParticipants: 10, maxParticipants: 20)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["participants_config"] as? [String: Any]

            #expect(config?["min_participants"] as! Int == 10)
            #expect(config?["max_participants"] as! Int == 20)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testFullParticipantsConfig() {
        manager.participantsConfig = .init(hideParticipants: true, minParticipants: 10, maxParticipants: 20)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["participants_config"] as? [String: Any]

            #expect(config?["has_waitlist"] == nil)
            #expect(config?["hide_participants"] as! Bool == true)
            #expect(config?["min_participants"] as! Int == 10)
            #expect(config?["max_participants"] as! Int == 20)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
}

// MARK: - Teams Config
struct NewEventTeamsConfigTest {
    let manager = NewEventManager()
    
    // Set up basic data needed to be able to generate a dto
    init() {
        manager.title = "Test event title"
        manager.body = "Test event body"
        manager.image = "test-image-url"
        manager.sports = [Sport(name: "soccer", images: [])]
        manager.organizers = [GroupSelection(type: .Club)]
        manager.selectedVenueDescriptors = [VenueDescriptor(name: "test-venue", city: "test-city", state: "test-state", country: "test-country")]
    }
    
    @Test
    func testHasWaitlist() {
        manager.teamsConfig = .init(hasWaitlist: true)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["teams_config"] as? [String: Any]
            
            #expect(config?["has_waitlist"] as! Bool == true)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testHideTeams() {
        manager.teamsConfig = .init(hideTeams: true)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["teams_config"] as? [String: Any]
            
            #expect(config?["hide_teams"] as! Bool == true)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testMinMaxTeams() {
        manager.teamsConfig = .init(minTeams: 4, maxTeams: 10)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["teams_config"] as? [String: Any]

            #expect(config?["min_teams"] as! Int == 4)
            #expect(config?["max_teams"] as! Int == 10)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    func testFullTeamsConfig() {
        manager.teamsConfig = .init(hideTeams: true, minTeams: 4, maxTeams: 10)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]
            let config = event?["teams_config"] as? [String: Any]
            
            #expect(config?["has_waitlist"] == nil)
            #expect(config?["hide_teams"] as! Bool == true)
            #expect(config?["min_teams"] as! Int == 4)
            #expect(config?["max_teams"] as! Int == 10)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
}

// MARK: - Validation
struct NewEventValidationTests {
    let manager = NewEventManager()

    // Set up an event that passes every rule, so each test only has to break
    // the one thing it is about.
    init() {
        manager.title = "Test event title"
        manager.body = "Test event body"
        manager.image = "test-image-url"
        manager.sports = [Sport(name: "soccer", images: [])]
        manager.organizers = [GroupSelection(type: .Club)]
        manager.selectedVenueDescriptors = [VenueDescriptor(name: "test-venue", city: "test-city", state: "test-state", country: "test-country")]
        manager.startDate = Date()
        manager.endDate = Date().addingTimeInterval(60 * 60)
    }

    @Test
    func testValidEventHasNoError() {
        #expect(manager.validationError() == nil)
    }

    @Test
    func testRecurrenceEndingBeforeStartIsRejected() {
        manager.recurrenceOptions = .init(
            pattern: .weekly,
            endTime: manager.startDate.addingTimeInterval(-60),
            interval: 1
        )
        #expect(manager.validationError() == .badRecurrence)
    }

    @Test
    func testRecurrenceEndingAfterStartIsAccepted() {
        manager.recurrenceOptions = .init(
            pattern: .weekly,
            endTime: manager.startDate.addingTimeInterval(60 * 60 * 24 * 7),
            interval: 1
        )
        #expect(manager.validationError() == nil)
    }

    @Test
    func testNoRecurrenceIsAccepted() {
        manager.recurrenceOptions = nil
        #expect(manager.validationError() == nil)
    }
}

// MARK: - NewEvent Dao
struct NewEventDaoTests {
    let manager = NewEventManager()
    
    // Set up basic data needed to be able to generate a dto
    init() {
        manager.title = "Test event title"
        manager.body = "Test event body"
        manager.image = "test-image-url"
        manager.sports = [Sport(name: "soccer", images: [])]
        manager.organizers = [GroupSelection(type: .Club)]
        manager.selectedVenueDescriptors = [VenueDescriptor(name: "test-venue", city: "test-city", state: "test-state", country: "test-country")]
    }
    
    @Test
    func testEventTypeIsSentAsTheServerString() {
        manager.type = .Class
        let dto = manager.generateEventDTO()

        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]

            #expect(event?["type"] as? String == "CLASS")
        } catch {
            Issue.record("Failed to parse json")
        }
    }

    @Test
    func testDefaultEventTypeIsRegular() {
        let dto = manager.generateEventDTO()

        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let event = json?["event"] as? [String: Any]

            #expect(event?["type"] as? String == "REGULAR")
        } catch {
            Issue.record("Failed to parse json")
        }
    }

    @Test
    func testIncludeHostOption() {
        var dto = manager.generateEventDTO()
        dto?.includeHost = false
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            #expect(json?["include_host"] as! Bool == false)
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testDailyRecurrenceOption() {
        let timestamp = Date()
        manager.recurrenceOptions = .init(pattern: .daily, endTime: timestamp, interval: 3)
        let dto = manager.generateEventDTO()

        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let config = json?["recurrence"] as? [String: Any]

            #expect(config?["pattern"] as! String == "DAILY")
            #expect(config?["interval"] as! Int == 3)
        } catch {
            Issue.record("Failed to parse json")
        }
    }

    @Test
    func testMonthlyRecurrenceOption() {
        let timestamp = Date()
        manager.recurrenceOptions = .init(pattern: .monthly, endTime: timestamp, interval: 1)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let config = json?["recurrence"] as? [String: Any]

            #expect(config?["pattern"] as! String == "MONTHLY")
            #expect(config?["interval"] as! Int == 1)
            #expect(config?["end_time"] as! String == timestamp.ISO8601Format())
        } catch {
            Issue.record("Failed to parse json")
        }
    }
    
    @Test
    func testWeeklyRecurrenceOption() {
        let timestamp = Date()
        manager.recurrenceOptions = .init(pattern: .weekly, endTime: timestamp, interval: 2)
        let dto = manager.generateEventDTO()
        
        guard let data = EncodeToData(dto) else {
            Issue.record("Failed to encode event dto to data")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let config = json?["recurrence"] as? [String: Any]

            #expect(config?["pattern"] as! String == "WEEKLY")
            #expect(config?["interval"] as! Int == 2)
            #expect(config?["end_time"] as! String == timestamp.ISO8601Format())
        } catch {
            Issue.record("Failed to parse json")
        }
    }
}
