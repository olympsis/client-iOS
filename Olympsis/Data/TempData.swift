//
//  TempData.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import Foundation

let _current_date = Date()
let _one_hr = Calendar.current.date(byAdding: .hour, value: 1, to: _current_date)
let _one_hr_interval = _one_hr?.timeIntervalSince(_current_date)

let USER_SNIPPETS = [
    UserSnippet(uuid: UUID().uuidString, username: "johnDoe", imageURL: "feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"),
    UserSnippet(uuid: UUID().uuidString, username: "janeDoe", imageURL: "feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg")
]

let COMMENTS = [
    Comment(id: UUID().uuidString, text: "Lets go!!!", user: USER_SNIPPETS[1], createdAt: 1639364779)
]

let POSTS = [
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: nil, likes: nil, comments: [COMMENTS[0]], createdAt: 1639364779, externalLink: "https://google.com"),
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], likes: nil, comments: [COMMENTS[0]], createdAt: 1639364779, externalLink: "google.com")
]

let FIELDS = [
    Field(id: UUID().uuidString, name: "Richard Building Fields", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The Richard Building fields is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America"),
    Field(id: UUID().uuidString, name: "Indoor Practice Facility", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America"),
    Field(id: UUID().uuidString, name: "11th Ave Park", owner: Ownership(name: "Salt Lake City", type: "public"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Salt Lake City", state: "UT", country: "United States of America")
]


let CLUBS = [
    Club(id: "609f6db90c34d41863a0e721", parent: nil, type: "club", name: "International Soccer Club", description: "Club in salt lake for people to come together and play soccer", sport: "soccer", city: "Salt Lake City", state: "UT", country: "United States", imageURL: "club-images/9515239B-C8B3-4C30-8E8B-8FD001EC5456.jpeg", imageGallery: [""], visibility: "public", members: [
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil)
    ], rules: nil, pinnedPostId: POSTS[0].id, createdAt: nil),
    Club(id: UUID().uuidString, parent: nil, type: "organization", name: "Lehi Soccer", description: "Club in salt lake for people to come together and play soccer", sport: "soccer", city: "Salt Lake City", state: "UT", country: "United States", imageURL: "club-images/E8ABDD5D-7E87-475A-8095-6D42676DC1E0.jpeg", imageGallery: [""], visibility: "public", members: [
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil)
    ], rules: nil, pinnedPostId: POSTS[0].id, createdAt: nil)
]

let ORGANIZATIONS = [
    Organization(id: UUID().uuidString, name: "Utah Soccer", description: "Organization that organizes soccer all over utah.", sport: "soccer", city: "Salt Lake City", state: "Utah", country: "United States", imageURL: "club-images/E8ABDD5D-7E87-475A-8095-6D42676DC1E0.jpeg", imageGallery: [""], members: nil, pinnedPostId: nil, createdAt: nil)
]

let ORGANIZATION_APPLICATIONS = [
    OrganizationApplication(id: "", organizationID: "", clubID: "", status: "pending", data: OrganizationApplicationData(club: CLUBS[0]), createdAt: 1639364780)
]

let GROUP_SELECTIONS = [
    GroupSelection(type: .Club, club: CLUBS[0], organization: nil, posts: nil),
    GroupSelection(type: .Organization, club: nil, organization: ORGANIZATIONS[0], posts: nil)
]

let EVENTS = [
    Event(id: UUID().uuidString, type: "tournament", poster: USER_SNIPPETS[0], organizers: [Organizer(type: GROUP_TYPE.Club.rawValue, id: CLUBS[0].id ?? UUID().uuidString)], field:  FieldDescriptor(type: "internal", id: UUID().uuidString, name: nil, location: nil), imageURL: "soccer-0", title: "Pick Up Soccer International", body: "Lets go play boys!!!", sport: "soccer", level: 0, startTime: 1699806600, actualStartTime: 1699806600, stopTime: 1699806615, actualStopTime: 0, maxParticipants: 10, participants: [
        Participant(id: UUID().uuidString, user: USER_SNIPPETS[0], status: "yes", createdAt: 1639364780)
    ], visibility: "", createdAt: 1639364780,  clubs: CLUBS, organizations: ORGANIZATIONS, fieldData: FIELDS[0]),
]


let USERS_DATA = [
    UserData(uuid: UUID().uuidString, username: "johndoe", firstName: "John", lastName: "Doe", imageURL: "profile-images/2F237A05-44E7-4356-9202-1D950B22649A.jpeg", visibility: "public", bio: "Love to play soccer", clubs: nil, sports: nil, deviceToken: nil),
    UserData(uuid: UUID().uuidString, username: "janedoe", firstName: "Jane", lastName: "Doe", imageURL: "", visibility: "private", bio: "Born and raised Utah. Love to snowboard.", clubs: nil, sports: nil, deviceToken: nil)
]

let USERS = [
    User(uuid: "", username: "", bio: "", imageURL: "", visibility: "", sports: nil, deviceToken: "")
]

let ANNOUCEMENTS = [
    Announcement(id: "0", image: "https://storage.googleapis.com/olympsis-feed-images/89b037d3-e4d6-4e65-86a4-27ef09983489.jpg"),
    Announcement(id: "1", image: "https://storage.googleapis.com/olympsis-feed-images/072bb74c-bebe-449d-9d1f-efe26b974081.jpg")
]

let CLUB_APPLICATIONS = [
    ClubApplication(id: "", uuid: "", clubID: "", status: "pending", data: UserData(uuid: "", username: "johndoe", firstName: "John", lastName: "Doe", imageURL: "", visibility: "", bio: nil, clubs: nil, sports: nil, deviceToken: nil), createdAt: 1685813111)
]

// Preview data
let GROUPS = [
    GroupSelection(type: GROUP_TYPE.Club, club: CLUBS[0], organization: nil),
    GroupSelection(type: GROUP_TYPE.Club, club: CLUBS[1], organization: nil),
    GroupSelection(type: GROUP_TYPE.Organization, club: nil, organization: ORGANIZATIONS[0])
]

let ROOMS = [
    Room(id: "", name: "Admin's Chat", type: "Group", group: GroupModel(id: UUID().uuidString, type: "club"), members: [ChatMember](), history: [Message]())
]

let INVITATIONS = [
    Invitation(id: UUID().uuidString, type: "organization", sender: UUID().uuidString, recipient: UUID().uuidString, subjectID: ORGANIZATIONS[0].id ?? UUID().uuidString, status: "pending", data: InvitationData(club: nil, event: nil, organization: ORGANIZATIONS[0]), createdAt:Int(Date().timeIntervalSinceNow))
]
