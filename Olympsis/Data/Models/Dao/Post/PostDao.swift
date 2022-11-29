//
//  PostDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import Foundation

class PostDao: Dao {
    let owner:  String
    let clubId: String
    let body:   String
    let images: [String]?
    
    init(owner: String, clubId: String, body: String, images: [String]? = nil) {
        self.owner = owner
        self.clubId = clubId
        self.body = body
        self.images = images
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(owner, forKey: .owner)
        try container.encode(clubId, forKey: .clubId)
        try container.encode(body, forKey: .body)
        if let _images = self.images {
            try container.encode(_images, forKey: .images)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case owner = "owner"
        case clubId = "clubId"
        case body = "body"
        case images = "images"
    }
}
