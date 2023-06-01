//
//  TempData.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import Foundation

let FIELDS = [
    Field(id: "000", name: "Richard Building Fields", owner: Ownership(name: "Brigham Young University", type: "private"), description: "ust right across the way from the Orem Fitness Center and Mountain View High School, Community Park is a very large park with lots to offer residents. It has 5 baseball fields, 9 tennis courts, and plenty of open space for soccer, football, and outdoor games.", sports: ["soccer", "pickleball"], images: [""], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America")
]


let CLUBS = [
    Club(id: "000", name: "SLC Soccer Club", description: "Club in salt lake for people to come together and play soccer", sport: "soccer", city: "Salt Lake City", state: "UT", country: "United States of America", imageURL: "", visibility: "public", members: [Member(id: "000", uuid: "111", role: "owner", data: UserData(uuid: "", username: "yomomma", firstName: "John", lastName: "Doe", imageURL: "", visibility: "public", bio: "", clubs: nil, sports: ["soccer","golf"], deviceToken: ""), joinedAt: nil)], rules: nil, createdAt: nil)
]


let EVENTS = [
    Event(id: "", poster: "", clubID: "", fieldID: "", imageURL: "", title: "", body: "", sport: "", level: 1, status: "", startTime: 0, actualStartTime: 0, stopTime: 0, maxParticipants: 0, participants: [
        Participant(id: "", uuid: "", data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "", createdAt: 0)
    ], likes: [Like](), visibility: "", createdAt: 0)
]


let POSTS = [
    Post(id: "", owner: "", clubId: "", body: "", images: nil, likes: nil, comments: nil, createdAt: 0)
]

let USERS_DATA = [
    UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: nil, clubs: nil, sports: nil, deviceToken: nil)
]

let USERS = [
    User(uuid: "", username: "", bio: "", imageURL: "", visibility: "", sports: nil, deviceToken: "")
]
