//
//  EventsResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import Foundation

/// The Fields Response is a struct conforms to the response of the api to get a list of fields, and decodes it.
struct EventsResponse: Decodable {
    let totalEvents: Int
    let events: [Event]
    
    enum CodingKeys: String, CodingKey {
        case totalEvents
        case events
    }
}
