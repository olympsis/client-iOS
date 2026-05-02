//
//  TempData.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

// import HealthKit
import Foundation
import CoreLocation

let _current_date = Date()
let _one_hr = Calendar.current.date(byAdding: .hour, value: 1, to: _current_date)
let _one_hr_interval = _one_hr?.timeIntervalSince(_current_date)

@MainActor
let USER_SNIPPETS = [
    UserSnippet(userID: UUID().uuidString, username: "johnDoe", firstName: "John", lastName: "Doe", imageURL: "feed-images/5439973E-7695-48F4-B611-8371B8BDF767.jpeg"),
    UserSnippet(userID: UUID().uuidString, username: "janeDoe", firstName: "Jane", lastName: "Doe", imageURL: "feed-images/2E64B83A-FCF7-4589-8E17-923F496085E4.jpeg")
]

@MainActor
let COMMENTS = [
    Comment(id: UUID().uuidString, text: "Lets go!!!", user: USER_SNIPPETS[1], createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779)))
]

@MainActor
let EVENT_COMMENTS = [
    EventComment(id: UUID().uuidString, user: USER_SNIPPETS[1], text: "Lets go!!!", createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779)))
]

@MainActor
let POSTS = [
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: nil, likes: [Reaction(id: "", userID: "", user: nil, createdAt: Date())], comments: [COMMENTS[0]], externalLink: "https://google.com", isSensitive: true, createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779))),
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "Just finished an awesome 10-mile run! Felt great and managed to beat my personal best time!", event: nil, images: [
        "feed-images/9DC9A5CE-073E-4859-949C-9135D740DB85.jpeg",
        "feed-images/E9650FF7-5DE7-4D76-B886-7C3EC422A05E.jpeg",
        "feed-images/5D710804-0CAF-4371-8C88-0879B9FEF9F4.jpeg"

        ], likes: [Reaction](), comments: [COMMENTS[0]], externalLink: nil, isSensitive:false, createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779))),
    Post(id: UUID().uuidString, type: "advertisement", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], likes: [Reaction](), comments: [COMMENTS[0]], externalLink: "google.com", isSensitive: true, createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779)))
]

@MainActor
let VENUES = [
    Venue(id: UUID().uuidString, name: "Richard Building Fields", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The Richard Building fields is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["field-images/22aa23f7-5fb5-4c2e-b4fb-3a2943d492fc.jpg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States", bookingURL: "https://www.olympsis.com/signin", requiresBooking: true),
    Venue(id: UUID().uuidString, name: "Indoor Practice Facility", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America"),
    Venue(id: UUID().uuidString, name: "11th Ave Park", owner: Ownership(name: "Salt Lake City", type: "public"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Salt Lake City", state: "UT", country: "United States of America")
]

@MainActor
let VENUE_DESCRIPTORS = [
    VenueDescriptor(name: "Faultline Gardens Park", city: "New York", state: "New York", country: "United States", location: GeoJSON(type: "point", coordinates: [-111.861028, 40.760891])),
    VenueDescriptor(id: VENUES[0].id, name: "Richard Building Fields", city: "Provo", state: "Utah", country: "United States"),
    VenueDescriptor(id: VENUES[1].id, name: "Indoor Practice Facility", city: "Provo", state: "Utah", country: "United States")
]

@MainActor
let CLUBS = [
    Club(id: "609f6db90c34d41863a0e721", parent: nil, name: "International Soccer Club", logo: "club-images/2660b86a-47ef-4c9e-83ee-58824f7b77ce.jpeg", banner: "club-images/02f070c5-3b49-4f0c-9719-e005aae895db.jpeg", sports: ["soccer", "basketball", "tennis"], description: """
    G⚽️AL 🥅:
    - This group is for pickup soccer games 😄🤙🏻
    - Our goal is to bring everyone together for some fun, friendships and sportsmanship.
    - No trash talking. No provoking. No discriminating. No harassing.
    - We watch for each other and we help each other.
    (When things are out of control, we will need to contact the authorities. Some of the buildings/ fields may require student ID / driver license occasionally)
    ======
    🛑 SAFETY 🛑
    No weapon. No harassment. No violence. No alcohol/drug. No racism.
    If seen, please report immediately
    🚔 BYU police are on campus 24/7, the main office is in JKB building - just one street away from the RB (next traffic light, opposite the Visiting Center)
    👮 If you need assistance outside of BYU campus, contact the Provo police
    =====
    ⚠️ LIABILITY ⚠️
    You are responsible for your own injury/risk and medical care (ACL etc)
    You are responsible for any citation if you violate the law (carrying illegal item, creating a fight, parking on a wrong spot etc)
    You are responsible for any fee if you damage public or private item that doesn't belong to you (breaking a window etc)
    You are responsible for own personal belongings (watch, wallet etc)
    ====
    ♻️ Field Rules ♻️
    Try to keep the field clean.
    Put your trashes in the trash cans.
    Help cleaning up the field.
    =====
    🔈 Page Rules 🔈
    No Spamming.
    No Advertising (unless you are selling your own soccer gears or have the approval to promote something helpful to the community).
""", city: "Salt Lake City", state: "UT", country: "United States", location: GeoJSON(type: "Point", coordinates: []), visibility: "public", members: [
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[1], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil),
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil)
    ], rules: [], tags: ["casual", "beginner-friendly", "outdoor", "indoor"], pinnedPosts: [POSTS[0].id], createdAt: Date(timeIntervalSince1970: 1639364779)),
    Club(id: UUID().uuidString, parent: nil, name: "Lehi Soccer", logo: nil, banner: nil, sports: ["soccer"], description: "Club in salt lake for people to come together and play soccer", city: "Salt Lake City", state: "UT", country: "United States", location: GeoJSON(type: "Point", coordinates: []), visibility: "public", members: [
        Member(id: UUID().uuidString, role: "owner", user: USER_SNIPPETS[0], joinedAt: nil)
    ], rules: [], pinnedPosts: [POSTS[0].id], createdAt: Date(timeIntervalSince1970: 1639364779))
]

@MainActor
let ORGANIZATIONS = [
    Organization(id: UUID().uuidString, name: "Utah Soccer", description: "Organization that organizes soccer all over utah.", sports: ["soccer", "tennis"], city: "Salt Lake City", state: "Utah", country: "United States", logo: "club-images/E8ABDD5D-7E87-475A-8095-6D42676DC1E0.jpeg", banner: nil, members: [], blackList: [], pinnedPosts: [], isVerified: false, createdAt: Date()),
    Organization(id: UUID().uuidString, name: "SLC Run Club", description: "Organization that organizes soccer all over utah.", sports: ["running"], city: "Salt Lake City", state: "Utah", country: "United States", logo: nil, banner: nil, members: [], blackList: [], pinnedPosts: [], isVerified: false, createdAt: Date())
]


@MainActor
let CLUB_SNIPPETS = [
    ClubSnippet(id: CLUBS[0].id, name: "International Soccer Club", description: "Club in salt lake for people to come together and play soccer", sports: ["soccer", "tennis"], city: "Salt Lake City", state: "Utah", country: "United States", visibility: "public")
]

@MainActor
let ORG_SNIPPETS = [
    OrgSnippet(id: ORGANIZATIONS[0].id, name: "Utah Soccer", description: "Club in salt lake for people to come together and play soccer", sports: ["soccer", "tennis"], city: "Salt Lake City", state: "Utah", country: "United States")
]

@MainActor
let ORGANIZATION_APPLICATIONS = [
    OrganizationApplication(id: UUID().uuidString, status: "pending", club: CLUBS[0], createdAt: 1639364780)
]

@MainActor
let GROUP_SELECTIONS = [
    GroupSelection(type: .Club, club: CLUBS[0], organization: nil, posts: nil),
    GroupSelection(type: .Organization, club: nil, organization: ORGANIZATIONS[0], posts: nil)
]

@MainActor
let EVENTS = [
    Event(
        id: UUID().uuidString,
        poster: USER_SNIPPETS[0],
        organizers: [
            Organizer(type: GROUP_TYPE.Club, id: CLUBS[0].id),
            Organizer(type: GROUP_TYPE.Club, id: CLUBS[1].id)
        ],
        venues: VENUE_DESCRIPTORS,
        mediaURL: "event-media/0713b70f-4bbc-49ac-b417-7f98ff70f57e.jpg",
        mediaType: .image,
        title: "Pick Up Soccer International",
        body: "Lets go play boys!!!",
        tags: [],
        sports: ["soccer"],
        formatConfig: EventFormatConfig(formats: [.versus5, .winnerStaysOn]),
        startTime: Date(),
        stopTime: Date().addingTimeInterval(TimeInterval(60 * 60 * 24)),
        participants: [
            Participant(
                id: UUID().uuidString,
                user: USER_SNIPPETS[0],
                status: .Yes,
                isAnonymous: true,
                createdAt: Date()
            )
        ],
        participantsWaitlist: [],
        participantsConfig: ParticipantsConfig(
            hasWaitlist: false,
            minParticipants: nil,
            maxParticipants: 10
        ),
        teams: [],
        teamsWaitlist: [],
        teamsConfig: nil,
        comments: [],
        visibility: .Public,
        externalLinks: nil,
        isSensitive: false,
        createdAt: Date()
    ),
    Event(
        id: UUID().uuidString,
        poster: USER_SNIPPETS[0],
        organizers: [Organizer(type: GROUP_TYPE.Club, id: CLUBS[0].id)],
        venues: VENUE_DESCRIPTORS,
        mediaURL: "soccer-0",
        mediaType: .image,
        title: "Pick Up Soccer International",
        body: "<p>Adult Pickleball is back on for spring! 🌸 Event is on the 5th floor. Bring a paddle and a friend (let me know if you need one)</p><p>This is the location: 217 E. 87th St, New York, NY</p><p></p><p>In association with the Phoenix sober movement </p>",
        tags: [],
        sports: ["soccer"],
        config: EventConfig(
            hidePoster: true,
            hideLocation: true
        ),
        formatConfig: nil,
        startTime: Date(timeIntervalSince1970: 1699806600),
        stopTime: Date(timeIntervalSince1970: 1699806615),
        participants: [
            Participant(
                id: UUID().uuidString,
                user: USER_SNIPPETS[0],
                status: .Yes,
                createdAt: Date(timeIntervalSince1970: 1639364780)
            )
        ],
        participantsWaitlist: [],
        participantsConfig: ParticipantsConfig(
            hasWaitlist: false,
            hideParticipants: true,
            minParticipants: nil,
            maxParticipants: 10
        ),
        teams: [],
        teamsWaitlist: [],
        teamsConfig: nil,
        comments: [],
        visibility: .Public,
        externalLinks: nil,
        isSensitive: true,
        createdAt: Date(timeIntervalSince1970: 1639364780)
    ),
]

@MainActor
let USERS_DATA = [
    User(userID: UUID().uuidString, username: "johndoe", firstName: "John", lastName: "Doe", gender: Gender.Male, birthdate: nil, imageURL: "profile-images/2F237A05-44E7-4356-9202-1D950B22649A.jpeg", bio: "Love to play soccer", sports: nil, visibility: "public", clubs: nil),
    User(userID: UUID().uuidString, username: "janedoe", firstName: "Jane", lastName: "Doe", gender: Gender.Female, birthdate: nil, imageURL: "", bio: "Born and raised Utah. Love to snowboard.", sports: nil, visibility: "private", clubs: nil)
]

@MainActor
let ANNOUCEMENTS = [
    Announcement(id: "0", image: "feed-images/89b037d3-e4d6-4e65-86a4-27ef09983489.jpg"),
    Announcement(id: "1", image: "feed-images/072bb74c-bebe-449d-9d1f-efe26b974081.jpg")
]

@MainActor
let CLUB_APPLICATIONS = [
    ClubApplication(id: UUID().uuidString, applicant: USERS_DATA[0], status: "pending", createdAt: Date(timeIntervalSince1970: TimeInterval(1685813111)))
]

@MainActor
let GROUPS = [
    GroupSelection(type: GROUP_TYPE.Club, club: CLUBS[0], organization: nil),
    GroupSelection(type: GROUP_TYPE.Club, club: CLUBS[1], organization: nil),
    GroupSelection(type: GROUP_TYPE.Organization, club: nil, organization: ORGANIZATIONS[0])
]

@MainActor
let ROOMS = [
    Room(id: "", name: "Admin's Chat", type: "Group", group: GroupModel(id: UUID().uuidString, type: "club"), members: [ChatMember](), history: [Message]())
]

@MainActor
let INVITATIONS = [
    Invitation(id: UUID().uuidString, type: "organization", sender: UUID().uuidString, recipient: UUID().uuidString, subjectID: ORGANIZATIONS[0].id, status: "pending", data: InvitationData(club: nil, event: nil, organization: ORGANIZATIONS[0]), createdAt:Date())
]

@MainActor
let POST_REPORTS = [
    PostReport(id: UUID().uuidString, post: POSTS[0], type: "Sensitive Content", notes: "It's pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: Date(timeIntervalSince1970: TimeInterval(1711060275)))
]

@MainActor
let EVENT_REPORTS = [
    EventReport(id: UUID().uuidString, type: "Other Issue", event: EVENTS[0], notes: "It's pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: Date(timeIntervalSince1970: TimeInterval(1711060275)))
]

@MainActor
let MEMBER_REPORTS = [
    MemberReport(id: UUID().uuidString, member: USER_SNIPPETS[0], type: "Other Issue", notes: "It's pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: Date(timeIntervalSince1970: TimeInterval(1711060275)))
]

@MainActor
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

@MainActor
let SPORTS_TEMP = [
    Sport(name: "soccer", images: []),
    Sport(name: "basketball", images: []),
    Sport(name: "football", images: []),
    Sport(name: "swimming", images: []),
    Sport(name: "running", images: []),
    Sport(name: "strength", images: []),
    Sport(name: "yoga", images: [])
]

@MainActor
let TAGS_TEMP = [
    Tag(name: "beginner-friendly"),
    Tag(name: "family-friendly"),
    Tag(name: "indoor"),
    Tag(name: "outdoor"),
    Tag(name: "open-to-all"),
]

@MainActor
let WORKOUTS = [
    Workout(
        type: .soccer,
        workout: WorkoutData(startDate: Date(), endDate: Date())
    )
]
