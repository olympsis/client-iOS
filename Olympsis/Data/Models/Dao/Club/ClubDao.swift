//
//  ClubDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/27/22.
//

import Foundation

class ClubDao: Dao {
    var name:           String
    var description:    String
    var sport:          String
    var city:           String
    var state:          String
    var country:        String
    var imageURL:       String
    var isPrivate:      Bool
    var isVisible:      Bool
    var rules:          [String]
    
    init(_name: String, _description: String, _sport: String, _city: String, _state: String, _country: String, _imageURL: String, _isPrivate: Bool, _isVisible: Bool, _rules: [String]) {
        self.name = _name
        self.description = _description
        self.sport = _sport
        self.city = _city
        self.state = _state
        self.country = _country
        self.imageURL = _imageURL
        self.isPrivate = _isPrivate
        self.isVisible = _isVisible
        self.rules = _rules
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(sport, forKey: .sport)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(country, forKey: .country)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(isPrivate, forKey: .isPrivate)
        try container.encode(isVisible, forKey: .isVisible)
        try container.encode(rules, forKey: .rules)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case sport
        case city
        case state
        case country
        case imageURL
        case isPrivate
        case isVisible
        case members
        case rules
        case createdAt
    }
}
