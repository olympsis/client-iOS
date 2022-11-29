//
//  UpdateUserDataDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import Foundation

class UpdateUserDataDao: Dao {
    let username:   String
    let bio:        String
    let imageURL:   String
    let clubs:      [String]
    let isPublic:   Bool
    let sports:     [String]
    
    init(_username: String, _bio: String, _imageURL: String, _clubs: [String], _isPublic: Bool, _sports: [String]) {
        self.username = _username
        self.bio = _bio
        self.imageURL = _imageURL
        self.clubs = _clubs
        self.isPublic = _isPublic
        self.sports = _sports
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(bio, forKey: .bio)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(clubs, forKey: .clubs)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(sports, forKey: .sports)
    }
    
    enum CodingKeys: String, CodingKey {
        case username
        case bio
        case imageURL
        case clubs
        case isPublic
        case sports
    }
}
