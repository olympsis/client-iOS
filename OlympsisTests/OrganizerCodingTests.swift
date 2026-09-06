//
//  OrganizerCodingTests.swift
//  OlympsisTests
//
//  Created by Joel Joseph on 9/6/26.
//

import Testing
import Foundation
@testable import Olympsis

/// `Organizer.type` crosses the wire as the server's string ("GROUP" /
/// "ORGANIZATION"), but older payloads still carry the legacy int. These pin
/// both directions so a change to `GROUP_TYPE` can't silently break either.
struct OrganizerCodingTests {

    @Test
    func testEncodesClubAsGroupString() {
        let organizer = Organizer(type: .Club, id: "club-id")

        guard let data = EncodeToData(organizer) else {
            Issue.record("Failed to encode organizer to data")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            #expect(json?["type"] as? String == "GROUP")
            #expect(json?["id"] as? String == "club-id")
        } catch {
            Issue.record("Failed to parse json")
        }
    }

    @Test
    func testEncodesOrganizationAsOrganizationString() {
        let organizer = Organizer(type: .Organization, id: "org-id")

        guard let data = EncodeToData(organizer) else {
            Issue.record("Failed to encode organizer to data")
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            #expect(json?["type"] as? String == "ORGANIZATION")
        } catch {
            Issue.record("Failed to parse json")
        }
    }

    @Test
    func testDecodesStringType() throws {
        let data = Data(#"{"type":"ORGANIZATION","id":"org-id"}"#.utf8)
        let organizer = try JSONDecoder().decode(Organizer.self, from: data)
        #expect(organizer.type == .Organization)
        #expect(organizer.id == "org-id")
    }

    @Test
    func testDecodesLegacyIntType() throws {
        let data = Data(#"{"type":1,"id":"org-id"}"#.utf8)
        let organizer = try JSONDecoder().decode(Organizer.self, from: data)
        #expect(organizer.type == .Organization)
    }
}
