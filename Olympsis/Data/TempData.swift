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
    UserSnippet(uuid: UUID().uuidString, username: "johnDoe", imageURL: "feed-images/5439973E-7695-48F4-B611-8371B8BDF767.jpeg"),
    UserSnippet(uuid: UUID().uuidString, username: "janeDoe", imageURL: "feed-images/2E64B83A-FCF7-4589-8E17-923F496085E4.jpeg")
]

let COMMENTS = [
    Comment(id: UUID().uuidString, text: "Lets go!!!", user: USER_SNIPPETS[1], createdAt: 1639364779)
]

let POSTS = [
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: nil, likes: [Like(id: "", uuid: "", user: nil, createdAt: 0)], comments: [COMMENTS[0]], externalLink: "https://google.com", isSensitive: true, createdAt: 1639364779),
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "Just finished an awesome 10-mile run! 🏃‍♂️💨 Felt great and managed to beat my personal best time!", event: nil, images: [
        "feed-images/9DC9A5CE-073E-4859-949C-9135D740DB85.jpeg",
        "feed-images/E9650FF7-5DE7-4D76-B886-7C3EC422A05E.jpeg",
        "feed-images/5D710804-0CAF-4371-8C88-0879B9FEF9F4.jpeg"

        ], likes: [Like](), comments: [COMMENTS[0]], externalLink: nil, isSensitive:false, createdAt: 1639364779),
    Post(id: UUID().uuidString, type: "advertisement", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], likes: [Like](), comments: [COMMENTS[0]], externalLink: "google.com", isSensitive: true, createdAt: 1639364779)
]

let FIELDS = [
    Venue(id: UUID().uuidString, name: "Richard Building Fields", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The Richard Building fields is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["field-images/22aa23f7-5fb5-4c2e-b4fb-3a2943d492fc.jpg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America"),
    Venue(id: UUID().uuidString, name: "Indoor Practice Facility", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America"),
    Venue(id: UUID().uuidString, name: "11th Ave Park", owner: Ownership(name: "Salt Lake City", type: "public"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Salt Lake City", state: "UT", country: "United States of America")
]

let VENUE_DESCRIPTORS = [
    VenueDescriptor(name: "Faultline Gardens Park", city: "New York", state: "New York", country: "United States", location: GeoJSON(type: "point", coordinates: [-111.861028, 40.760891])),
    VenueDescriptor(id: FIELDS[0].id, name: "Richard Building Fields", city: "Provo", state: "Utah", country: "United States"),
    VenueDescriptor(id: FIELDS[1].id, name: "Indoor Practice Facility", city: "Provo", state: "Utah", country: "United States")
]

let CLUBS = [
    Club(id: "609f6db90c34d41863a0e721", parent: nil, name: "International Soccer Club", logo: "club-images/2660b86a-47ef-4c9e-83ee-58824f7b77ce.jpeg", banner: "club-images/02f070c5-3b49-4f0c-9719-e005aae895db.jpeg", sports: ["soccer", "basketball", "tennis"], description: "Club in salt lake for people to come together and play soccer", city: "Salt Lake City", state: "UT", country: "United States", visibility: "public", members: [
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[1], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil)
    ], rules: nil, pinnedPosts: [POSTS[0].id ?? ""], createdAt: 1639364779),
    Club(id: UUID().uuidString, parent: nil, name: "Lehi Soccer", logo: "", banner: "", sports: ["soccer"], description: "Club in salt lake for people to come together and play soccer", city: "Salt Lake City", state: "UT", country: "United States", visibility: "public", members: [
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil)
    ], rules: nil, pinnedPosts: [POSTS[0].id ?? ""], createdAt: 1639364779)
]

let ORGANIZATIONS = [
    Organization(id: UUID().uuidString, name: "Utah Soccer", description: "Organization that organizes soccer all over utah.", sports: ["soccer", "tennis"], city: "Salt Lake City", state: "Utah", country: "United States", logo: "club-images/E8ABDD5D-7E87-475A-8095-6D42676DC1E0.jpeg", banner: nil, members: [], blackList: nil, pinnedPosts: nil, isVerified: false, createdAt: 0),
    Organization(id: UUID().uuidString, name: "SLC Run Club", description: "Organization that organizes soccer all over utah.", sports: ["running"], city: "Salt Lake City", state: "Utah", country: "United States", logo: nil, banner: nil, members: [], blackList: nil, pinnedPosts: nil, isVerified: false, createdAt: nil)
]


let CLUB_SNIPPETS = [
    ClubSnippet(id: CLUBS[0].id, name: "International Soccer Club", description: "Club in salt lake for people to come together and play soccer", sports: ["soccer", "tennis"], city: "Salt Lake City", state: "Utah", country: "United States", visibility: "public")
]

let ORG_SNIPPETS = [
    OrgSnippet(id: ORGANIZATIONS[0].id ?? UUID().uuidString, name: "Utah Soccer", description: "Club in salt lake for people to come together and play soccer", sports: ["soccer", "tennis"], city: "Salt Lake City", state: "Utah", country: "United States")
]

let ORGANIZATION_APPLICATIONS = [
    OrganizationApplication(id: UUID().uuidString, status: "pending", club: CLUBS[0], createdAt: 1639364780)
]

let GROUP_SELECTIONS = [
    GroupSelection(type: .Club, club: CLUBS[0], organization: nil, posts: nil),
    GroupSelection(type: .Organization, club: nil, organization: ORGANIZATIONS[0], posts: nil)
]

let EVENTS = [
    Event(
        id: UUID().uuidString,
        type: EVENT_TYPES.Competitive,
        poster: USER_SNIPPETS[0],
        organizers: [Organizer(type: GROUP_TYPE.Club, id: CLUBS[0].id)],
        venues: VENUE_DESCRIPTORS,
        imageURL: "event-images/soccer-0.jpg",
        title: "Pick Up Soccer International",
        body: "Lets go play boys!!!", 
        sports: ["soccer"],
        level: EVENT_SKILL_LEVELS.All,
        startTime: 1720696495,
        stopTime: 1699806615,
        maxParticipants: 10, 
        participants: [
            Participant(id: UUID().uuidString, user: USER_SNIPPETS[0], status: EVENT_RSVP_STATUS.Yes, createdAt: 1639364780)
        ],
        visibility: EVENT_VISIBILITY_TYPES.Public,
        createdAt: 1639364780,
        isSensitive: false
    ),
    Event(
        id: UUID().uuidString,
        type: EVENT_TYPES.Regular,
        poster: USER_SNIPPETS[0],
        organizers: [
            Organizer(
                type: GROUP_TYPE.Club, 
                id: CLUBS[0].id
            )
        ],
        venues: VENUE_DESCRIPTORS,
        imageURL: "soccer-0",
        title: "Pick Up Soccer International",
        body: "Lets go play boys!!!",
        sports: ["soccer"],
        level: EVENT_SKILL_LEVELS.All,
        startTime: 1699806600,
        stopTime: 1699806615,
        maxParticipants: 10,
        participants: [
            Participant(id: UUID().uuidString, user: USER_SNIPPETS[0], status: EVENT_RSVP_STATUS.Yes, createdAt: 1639364780)
        ],
        visibility: EVENT_VISIBILITY_TYPES.Public,
        createdAt: 1639364780,
        isSensitive: true
    ),
]


let USERS_DATA = [
    UserData(uuid: UUID().uuidString, username: "johndoe", firstName: "John", lastName: "Doe", imageURL: "profile-images/2F237A05-44E7-4356-9202-1D950B22649A.jpeg", bio: "Love to play soccer", sports: nil, visibility: "public", clubs: nil),
    UserData(uuid: UUID().uuidString, username: "janedoe", firstName: "Jane", lastName: "Doe", imageURL: "", bio: "Born and raised Utah. Love to snowboard.", sports: nil, visibility: "private", clubs: nil)
]

let ANNOUCEMENTS = [
    Announcement(id: "0", image: "feed-images/89b037d3-e4d6-4e65-86a4-27ef09983489.jpg"),
    Announcement(id: "1", image: "feed-images/072bb74c-bebe-449d-9d1f-efe26b974081.jpg")
]

let CLUB_APPLICATIONS = [
    ClubApplication(id: UUID().uuidString, applicant: USERS_DATA[0], status: "pending", createdAt: 1685813111)
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

let POST_REPORTS = [
    PostReport(id: UUID().uuidString, post: POSTS[0], type: "Sensitive Content", notes: "It’s pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: 1711060275)
]

let EVENT_REPORTS = [
    EventReport(id: UUID().uuidString, type: "Other Issue", event: EVENTS[0], notes: "It’s pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: 1711060275)
]

let MEMBER_REPORTS = [
    MemberReport(id: UUID().uuidString, member: USER_SNIPPETS[0], type: "Other Issue", notes: "It’s pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: 1711060275)
]

let SHARING_TEMPLATES = [
    EventSharingTemplate(
        titlePosition: .top_leading,
        timePosition: .bottom_leading,
        venuePosition: .bottom_leading
    ),
    
    EventSharingTemplate(
        titlePosition: .bottom_leading,
        timePosition: .center,
        venuePosition: .bottom_leading
    ),
    
    EventSharingTemplate(
        titlePosition: .center,
        timePosition: .center,
        venuePosition: .center
    ),
    
    EventSharingTemplate(
        titlePosition: .bottom_center,
        timePosition: .center,
        venuePosition: .bottom_center
    )
]
