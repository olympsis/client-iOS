//
//  Event.swift
//  OlympsisTests
//
//  Created by Joel on 12/17/23.
//

import XCTest

final class EventModel: XCTestCase {

    override func setUpWithError() throws {
        
        let orgID = UUID().uuidString
        let clubID = UUID().uuidString
        let fieldID = UUID().uuidString
        
        let clubData = ClubData(parent: ORGANIZATIONS[0])
        
        let club = Club(id: clubID, parentId: orgID, type: GROUP_TYPE.Club.rawValue, name: "Test Club", description: "Test description...", sport: SPORT.soccer.rawValue, city: "Salt Lake City", state: "UT", country: "United States", imageURL: "/club-images/test-image.jpeg", imageGallery: ["/club-images/image-1.jpeg","/club-images/image-2.jpeg"], visibility: "public", members: nil, rules: ["No hate speech.", "Be kind."], data: clubData, pinnedPostId: nil, createdAt: 1639364780)
        let event = Event(id: UUID().uuidString, type: "pickup", poster: UUID().uuidString,organizers: [Organizer(type: GROUP_TYPE.Club.rawValue, id: CLUBS[0].id ?? UUID().uuidString),Organizer(type: GROUP_TYPE.Organization.rawValue, id: ORGANIZATIONS[0].id ?? UUID().uuidString)], field:  FieldDescriptor(type: "internal", id: UUID().uuidString, location: nil), imageURL: "soccer-0", title: "Sunday Ball", body: "Lets go play boys!!!", sport: "soccer", level: 1, startTime: 1702688400, actualStartTime: nil, stopTime: nil, actualStopTime: 0, minParticipants: 10, maxParticipants: 0, participants: [
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "QuantumJester", firstName: "olympsis", lastName: "user", imageURL: "/profile-image/test-image.jpeg", visibility: "public", bio: "test bio", clubs: nil, sports: nil, deviceToken: nil), status: "yes", createdAt: 1639364780),
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "CelestialWhisper", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "yes", createdAt: 1639364780),
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "NebulaNomad", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "no", createdAt: 1639364780),
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "CrimsonWanderer", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "maybe", createdAt: 1639364780)
            
        ], visibility: "", data: EventData(poster: USERS_DATA[0], field: FIELDS[0], clubs: CLUBS, organizations: ORGANIZATIONS), createdAt: 1639364780)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let orgID = UUID().uuidString
        let clubID = UUID().uuidString
        let fieldID = UUID().uuidString
        
        let clubData = ClubData(parent: ORGANIZATIONS[0])
        
        let club = Club(id: clubID, parentId: orgID, type: GROUP_TYPE.Club.rawValue, name: "Test Club", description: "Test description...", sport: SPORT.soccer.rawValue, city: "Salt Lake City", state: "UT", country: "United States", imageURL: "/club-images/test-image.jpeg", imageGallery: ["/club-images/image-1.jpeg","/club-images/image-2.jpeg"], visibility: "public", members: nil, rules: ["No hate speech.", "Be kind."], data: clubData, pinnedPostId: nil, createdAt: 1639364780)
        let event = Event(id: UUID().uuidString, type: "pickup", poster: UUID().uuidString,organizers: [Organizer(type: GROUP_TYPE.Club.rawValue, id: CLUBS[0].id ?? UUID().uuidString),Organizer(type: GROUP_TYPE.Organization.rawValue, id: ORGANIZATIONS[0].id ?? UUID().uuidString)], field:  FieldDescriptor(type: "internal", id: UUID().uuidString, location: nil), imageURL: "soccer-0", title: "Sunday Ball", body: "Lets go play boys!!!", sport: "soccer", level: 1, startTime: 1702688400, actualStartTime: nil, stopTime: nil, actualStopTime: 0, minParticipants: 10, maxParticipants: 0, participants: [
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "QuantumJester", firstName: "olympsis", lastName: "user", imageURL: "/profile-image/test-image.jpeg", visibility: "public", bio: "test bio", clubs: nil, sports: nil, deviceToken: nil), status: "yes", createdAt: 1639364780),
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "CelestialWhisper", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "yes", createdAt: 1639364780),
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "NebulaNomad", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "no", createdAt: 1639364780),
            Participant(id: UUID().uuidString, uuid: "", data: UserData(uuid: "", username: "CrimsonWanderer", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "maybe", createdAt: 1639364780)
            
        ], visibility: "", data: EventData(poster: USERS_DATA[0], field: FIELDS[0], clubs: CLUBS, organizations: ORGANIZATIONS), createdAt: 1639364780)
        let json = EncodeToData(event)
        print(json)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
