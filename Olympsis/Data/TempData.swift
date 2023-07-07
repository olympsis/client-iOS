//
//  TempData.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import Foundation

let FIELDS = [
    Field(id: "000", name: "Richard Building Fields", owner: Ownership(name: "Brigham Young University", type: "private"), description: "Just right across the way from the Orem Fitness Center and Mountain View High School, Community Park is a very large park with lots to offer residents. It has 5 baseball fields, 9 tennis courts, and plenty of open space for soccer, football, and outdoor games.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America")
]


let CLUBS = [
    Club(id: "609f6db90c34d41863a0e721", name: "SLC Soccer Club", description: "Club in salt lake for people to come together and play soccer", sport: "soccer", city: "Salt Lake City", state: "UT", country: "United States of America", imageURL: "club-images/E8ABDD5D-7E87-475A-8095-6D42676DC1E0.jpeg", visibility: "public", members: [Member(id: "000", uuid: "111", role: "owner", data: UserData(uuid: "", username: "yomomma", firstName: "John", lastName: "Doe", imageURL: "", visibility: "public", bio: "", clubs: nil, sports: ["soccer","golf"], deviceToken: ""), joinedAt: nil)], rules: nil, createdAt: nil)
]


let EVENTS = [
    Event(id: "", poster: "", clubID: "", fieldID: "", imageURL: "soccer-0", title: "Pick Up Soccer International", body: "Lets go play boys!!!", sport: "soccer", level: 1, status: "pending", startTime: 1688792743, actualStartTime: 1688686344, stopTime: 0, maxParticipants: 0, participants: [
        Participant(id: "0", uuid: "", data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "yes", createdAt: 1639364780),
        Participant(id: "1", uuid: "", data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "yes", createdAt: 1639364780),
        Participant(id: "2", uuid: "", data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "no", createdAt: 1639364780),
        Participant(id: "3", uuid: "", data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "maybe", createdAt: 1639364780),
        Participant(id: "4", uuid: "", data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "maybe", createdAt: 1639364780),
        Participant(id: "4", uuid: "", data: UserData(uuid: "", username: "", firstName: "", lastName: "", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), status: "yes", createdAt: 1639364780)
        
    ], likes: [Like](), visibility: "", data: EventData(poster: USERS_DATA[0], club: CLUBS[0], field: FIELDS[0]), createdAt: 1639364780)
]


let POSTS = [
    Post(id: "0", poster: "", clubID: "", body: "It was a great day today", eventID: nil, images: nil, data: PostData(poster: nil, user: USERS_DATA[0], event: nil), likes: nil, comments: [
        Comment(id: "", uuid: "000", text: "Lets go!!!", data: USERS_DATA[1], createdAt: 1639364779)
    ], createdAt: 1639364779),
    Post(id: "1", poster: "", clubID: "", body: "Was it just me that saw this?", eventID: nil, images: [""], data: PostData(poster: nil, user: USERS_DATA[1], event: nil), likes: nil, comments: [
        Comment(id: "", uuid: "000", text: "Lets go!!!", data: USERS_DATA[0], createdAt: 1639364779)
    ], createdAt: 1639364780),
    Post(id: "2", poster: "", clubID: "", body: "Yooo it was litt today", eventID: nil, images: [""], data: PostData(poster: nil, user: USERS_DATA[0], event: nil), likes: nil, comments: [
        Comment(id: "", uuid: "000", text: "Lets go!!!", data: USERS_DATA[1], createdAt: 1639364779)
    ], createdAt: 1639364781)
]

let USERS_DATA = [
    UserData(uuid: "", username: "johndoe", firstName: "John", lastName: "Doe", imageURL: "", visibility: "", bio: nil, clubs: nil, sports: nil, deviceToken: nil),
    UserData(uuid: "", username: "janedoe", firstName: "Jane", lastName: "Doe", imageURL: "", visibility: "", bio: nil, clubs: nil, sports: nil, deviceToken: nil)
]

let USERS = [
    User(uuid: "", username: "", bio: "", imageURL: "", visibility: "", sports: nil, deviceToken: "")
]

let ANNOUCEMENTS = [
    Announcement(id: "0", image: "https://api.olympsis.com/feed-images/89b037d3-e4d6-4e65-86a4-27ef09983489.jpg"),
    Announcement(id: "1", image: "https://api.olympsis.com/feed-images/072bb74c-bebe-449d-9d1f-efe26b974081.jpg")
]

let CLUB_APPLICATIONS = [
    ClubApplication(id: "", uuid: "", clubID: "", status: "pending", data: UserData(uuid: "", username: "johndoe", firstName: "John", lastName: "Doe", imageURL: "", visibility: "", bio: "", clubs: nil, sports: nil, deviceToken: nil), createdAt: 1685813111)
]
