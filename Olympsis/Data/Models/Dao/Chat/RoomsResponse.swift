//
//  RoomsResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import Foundation

struct RoomsResponse: Decodable {
    let totalRooms: Int
    let rooms: [Room]
}
