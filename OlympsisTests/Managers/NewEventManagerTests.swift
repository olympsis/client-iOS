//
//  NewEventManagerTests.swift
//  OlympsisTests
//
//  Created by Joel on 1/26/24.
//

import XCTest
import Foundation

final class NewEventManagerTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let manager = NewEventManager()
        
        let fieldID = UUID().uuidString
        
        manager.type = .PickUp
        manager.title = "Event Title"
        manager.body = "Event Body"
        manager.externalLink = "Event External Link"
        manager.field = Field(id: fieldID, name: "Test Field", owner: Ownership(name: "Test", type: "private"), description: "Field Description", sports: ["soccer", "basketball"], images: ["field image 1", "field image 2"], location: GeoJSON(type: "Point", coordinates: [0.1, 0.2]), city: "Test City", state: "Test State", country: "Test Country")
        manager.organizers = [
            GroupSelection(type: GROUP_TYPE.Club, club: CLUBS[0]),
            GroupSelection(type: GROUP_TYPE.Organization, organization: ORGANIZATIONS[0])
        ]
        manager.startDate = Date(timeIntervalSince1970: TimeInterval(946713600))
        manager.endDate = Date(timeIntervalSince1970: TimeInterval(946717200))
        manager.minParticipants = 0
        manager.maxParticipants = 10
        manager.sport = .soccer
        manager.image = "Event Image"
        manager.skillLevel = .All
        manager.visibility = .Public
        
        let dao = try manager.generateNewEventData()
        XCTAssertNotNil(dao)
        
        XCTAssertEqual(dao?.type, EVENT_TYPES.PickUp.rawValue)
        XCTAssertEqual(dao?.title, "Event Title")
        XCTAssertEqual(dao?.body, "Event Body")
        XCTAssertEqual(dao?.externalLink, "Event External Link")
        XCTAssertEqual(dao?.field?.id, fieldID)
        XCTAssertEqual(dao?.organizers?[0].id, manager.organizers[0].club?.id)
        XCTAssertEqual(dao?.organizers?[1].id, manager.organizers[1].organization?.id)
        XCTAssertEqual(dao?.startTime, Int(manager.startDate.timeIntervalSince1970))
        XCTAssertEqual(dao?.stopTime, Int(manager.endDate.timeIntervalSince1970))
        XCTAssertEqual(dao?.sport, manager.sport.rawValue)
        XCTAssertEqual(dao?.level, manager.skillLevel.toInt())
        XCTAssertEqual(dao?.visibility, manager.visibility.rawValue)
        XCTAssertEqual(dao?.minParticipants, Int(manager.minParticipants))
        XCTAssertEqual(dao?.maxParticipants, Int(manager.maxParticipants))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
