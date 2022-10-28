//
//  User.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/21/22.
//

import Foundation

class User: Codable {
    private var firstName: String
    private var lastName: String
    private var email: String
    private var userName: String
    private var profileImage: String?
    private var sports: [String]?
    private var clubs: [String]?
    private var badges: [Badge]?
    private var trophies: [Trophy]?
    private var friends: [String]?
    
    
    init(firstName: String, lastName: String, email: String, userName: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.userName = userName
    }
    
    func getFirstName() -> String {
        return self.firstName
    }
    
    func getLastName() -> String {
        return self.lastName
    }
    
    func getName() -> String {
        return self.firstName + " " + self.lastName
    }
    
    func getEmail() -> String {
        return self.email
    }
    
    func getUserName() -> String {
        return self.userName
    }
    
    func updateUserName(name: String) {
        self.userName = name
    }
    
    func getProfileImageURL() -> String? {
        return self.profileImage
    }
    
    func updateProfileImageURL(url: String) {
        self.profileImage = url
    }
    
    func getSports() -> [String] {
        guard let sports = self.sports else {
            return [String]()
        }
        return sports
    }
    
    func updateSport(sports: [String]) {
        self.sports = sports
    }
    
    func getFriends() -> [String] {
        guard let friends = self.friends else {
            return [String]()
        }
        return friends
    }
    
    func updateFriends(friends: [String]) {
        self.friends = friends
    }
    
    func getClubs() -> [String] {
        guard let clubs = self.clubs else {
            return [String]()
        }
        return clubs
    }
    
    func updateClubs(clubs:[String]) {
        self.clubs = clubs
    }
    
    func getTrophies() -> [Trophy] {
        guard let trophies = self.trophies else {
            return [Trophy]()
        }
        return trophies
    }
    
    func updateTrophies(trophies:[Trophy]) {
        self.trophies = trophies;
    }
    
    func getBadges() -> [Badge] {
        guard let badges = self.badges else {
            return [Badge]()
        }
        return badges
    }
}
