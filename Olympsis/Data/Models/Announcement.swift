//
//  Announcement.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import Foundation

class Announcement: Encodable, Identifiable, Equatable {
    static func == (lhs: Announcement, rhs: Announcement) -> Bool {
        return false
    }
    
    var id: String
    var imageURL: URL
    
    init(id: String, image: String) {
        self.id = id
        self.imageURL = URL(string: image)!
    }
    
    enum CodingKeys: String, CodingKey{
        case id
        case imageURL
    }
}
