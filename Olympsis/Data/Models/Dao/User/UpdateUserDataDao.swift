//
//  UpdateUserDataDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import Foundation

class UpdateUserDataDao: Dao {
    let username:   String?
    let bio:        String?
    let imageURL:   String?
    let clubs:      [String]?
    let isPublic:   Bool?
    let sports:     [String]?
    let deviceToken: String?
    
    init(_username: String?=nil, _bio: String?=nil, _imageURL: String?=nil, _clubs: [String]?=nil, _isPublic: Bool?=nil, _sports: [String]?=nil, _deviceToken: String?=nil) {
        self.username = _username
        self.bio = _bio
        self.imageURL = _imageURL
        self.clubs = _clubs
        self.isPublic = _isPublic
        self.sports = _sports
        self.deviceToken = _deviceToken
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
        try container.encode(deviceToken, forKey: .deviceToken)
    }
    
    enum CodingKeys: String, CodingKey {
        case username
        case bio
        case imageURL
        case clubs
        case isPublic
        case sports
        case deviceToken
    }
}
