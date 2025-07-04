//
//  TempData.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/26/23.
//

import HealthKit
import Foundation
import CoreLocation

let _current_date = Date()
let _one_hr = Calendar.current.date(byAdding: .hour, value: 1, to: _current_date)
let _one_hr_interval = _one_hr?.timeIntervalSince(_current_date)

@MainActor
let USER_SNIPPETS = [
    UserSnippet(uuid: UUID().uuidString, username: "johnDoe", firstName: "John", lastName: "Doe", imageURL: "feed-images/5439973E-7695-48F4-B611-8371B8BDF767.jpeg"),
    UserSnippet(uuid: UUID().uuidString, username: "janeDoe", firstName: "Jane", lastName: "Doe", imageURL: "feed-images/2E64B83A-FCF7-4589-8E17-923F496085E4.jpeg")
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
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: nil, likes: [Reaction(id: "", uuid: "", user: nil, createdAt: Date())], comments: [COMMENTS[0]], externalLink: "https://google.com", isSensitive: true, createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779))),
    Post(id: UUID().uuidString, type: "post", poster: USER_SNIPPETS[0], body: "Just finished an awesome 10-mile run! 🏃‍♂️💨 Felt great and managed to beat my personal best time!", event: nil, images: [
        "feed-images/9DC9A5CE-073E-4859-949C-9135D740DB85.jpeg",
        "feed-images/E9650FF7-5DE7-4D76-B886-7C3EC422A05E.jpeg",
        "feed-images/5D710804-0CAF-4371-8C88-0879B9FEF9F4.jpeg"

        ], likes: [Reaction](), comments: [COMMENTS[0]], externalLink: nil, isSensitive:false, createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779))),
    Post(id: UUID().uuidString, type: "advertisement", poster: USER_SNIPPETS[0], body: "It was a great day today", event: nil, images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], likes: [Reaction](), comments: [COMMENTS[0]], externalLink: "google.com", isSensitive: true, createdAt: Date(timeIntervalSince1970: TimeInterval(1639364779)))
]

@MainActor
let VENUES = [
    Venue(id: UUID().uuidString, name: "Richard Building Fields", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The Richard Building fields is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["field-images/22aa23f7-5fb5-4c2e-b4fb-3a2943d492fc.jpg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America", bookingURL: "https://www.olympsis.com/signin", requiresBooking: true),
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
    You are responsible for any fee if you damage public or private item that doesn’t belong to you (breaking a window etc)
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
        mediaURL: "event-images/soccer-0.jpg",
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
        externalLink: nil,
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
        body: "Lets go play boys!!!",
        tags: [],
        sports: ["soccer"],
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
            minParticipants: nil,
            maxParticipants: 10
        ),
        teams: [],
        teamsWaitlist: [],
        teamsConfig: nil,
        comments: [],
        visibility: .Public,
        externalLink: nil,
        isSensitive: true,
        createdAt: Date(timeIntervalSince1970: 1639364780)
    ),
]

@MainActor
let USERS_DATA = [
    User(uuid: UUID().uuidString, username: "johndoe", firstName: "John", lastName: "Doe", gender: Gender.Male, birthdate: nil, imageURL: "profile-images/2F237A05-44E7-4356-9202-1D950B22649A.jpeg", bio: "Love to play soccer", sports: nil, visibility: "public", clubs: nil),
    User(uuid: UUID().uuidString, username: "janedoe", firstName: "Jane", lastName: "Doe", gender: Gender.Female, birthdate: nil, imageURL: "", bio: "Born and raised Utah. Love to snowboard.", sports: nil, visibility: "private", clubs: nil)
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
    PostReport(id: UUID().uuidString, post: POSTS[0], type: "Sensitive Content", notes: "It’s pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: Date(timeIntervalSince1970: TimeInterval(1711060275)))
]

@MainActor
let EVENT_REPORTS = [
    EventReport(id: UUID().uuidString, type: "Other Issue", event: EVENTS[0], notes: "It’s pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: Date(timeIntervalSince1970: TimeInterval(1711060275)))
]

@MainActor
let MEMBER_REPORTS = [
    MemberReport(id: UUID().uuidString, member: USER_SNIPPETS[0], type: "Other Issue", notes: "It’s pretty crazy what he posted here. We definitely should take this down before more people see this.", status: "pending", createdAt: Date(timeIntervalSince1970: TimeInterval(1711060275)))
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
    Sport(name: "⚽️ soccer", images: []),
    Sport(name: "🏀 basketball", images: []),
    Sport(name: "🏈 football", images: []),
    Sport(name: "🏊‍♂️ swimming", images: []),
    Sport(name: "🏃‍♂️ running", images: []),
    Sport(name: "🏋️‍♂️ strength", images: []),
    Sport(name: "🧘‍♂️ yoga", images: [])
]

@MainActor
let TAGS_TEMP = [
    Tag(name: "beginner-friendly"),
    Tag(name: "family-friendly"),
    Tag(name: "indoor"),
    Tag(name: "outdoor"),
    Tag(name: "open-to-all"),
]

let RUNNING_POINTS = [
    CLLocationCoordinate2D(latitude: 40.76090934923149, longitude: -111.86098559052753),
    CLLocationCoordinate2D(latitude: 40.76093855517691, longitude: -111.8610121643343),
    CLLocationCoordinate2D(latitude: 40.76092779343069, longitude: -111.8610543165328),
    CLLocationCoordinate2D(latitude: 40.76097176100934, longitude: -111.86107397260352),
    CLLocationCoordinate2D(latitude: 40.76092809746386, longitude: -111.86102146555585),
    CLLocationCoordinate2D(latitude: 40.760924399877, longitude: -111.86106055388855),
    CLLocationCoordinate2D(latitude: 40.76092886483961, longitude: -111.86101606545387),
    CLLocationCoordinate2D(latitude: 40.76088687867793, longitude: -111.86103309085973),
    CLLocationCoordinate2D(latitude: 40.76087801460852, longitude: -111.86104447989354),
    CLLocationCoordinate2D(latitude: 40.7608827277535, longitude: -111.861079595015),
    CLLocationCoordinate2D(latitude: 40.76088449727654, longitude: -111.86113579818327),
    CLLocationCoordinate2D(latitude: 40.760879209535375, longitude: -111.86111815875489),
    CLLocationCoordinate2D(latitude: 40.76088211052373, longitude: -111.86108316955915),
    CLLocationCoordinate2D(latitude: 40.76086038879463, longitude: -111.86110810488955),
    CLLocationCoordinate2D(latitude: 40.760868031025105, longitude: -111.8610743225011),
    CLLocationCoordinate2D(latitude: 40.76088899216481, longitude: -111.86111576860881),
    CLLocationCoordinate2D(latitude: 40.76091305309547, longitude: -111.86114783630589),
    CLLocationCoordinate2D(latitude: 40.76089009726959, longitude: -111.86117215473203),
    CLLocationCoordinate2D(latitude: 40.760864819528884, longitude: -111.86117725526923),
    CLLocationCoordinate2D(latitude: 40.76089479022949, longitude: -111.86123378404807),
    CLLocationCoordinate2D(latitude: 40.760887269750846, longitude: -111.86120235207942),
    CLLocationCoordinate2D(latitude: 40.76088510867565, longitude: -111.86123323318047),
    CLLocationCoordinate2D(latitude: 40.76090826127862, longitude: -111.86126641937854),
    CLLocationCoordinate2D(latitude: 40.7608985656457, longitude: -111.86124585393465),
    CLLocationCoordinate2D(latitude: 40.76092737173192, longitude: -111.86125695237006),
    CLLocationCoordinate2D(latitude: 40.76095145288658, longitude: -111.8612621636836),
    CLLocationCoordinate2D(latitude: 40.76096403085181, longitude: -111.86123152584575),
    CLLocationCoordinate2D(latitude: 40.76098381171017, longitude: -111.86121752519175),
    CLLocationCoordinate2D(latitude: 40.76097517272141, longitude: -111.86116698159881),
    CLLocationCoordinate2D(latitude: 40.761003810130184, longitude: -111.86121083152706),
    CLLocationCoordinate2D(latitude: 40.761044315153704, longitude: -111.86126154882756),
    CLLocationCoordinate2D(latitude: 40.76101194451908, longitude: -111.86122098180884),
    CLLocationCoordinate2D(latitude: 40.761026697784054, longitude: -111.86124465861757),
    CLLocationCoordinate2D(latitude: 40.7610392266713, longitude: -111.8612757512291),
    CLLocationCoordinate2D(latitude: 40.76107916514115, longitude: -111.86126377778938),
    CLLocationCoordinate2D(latitude: 40.761065576408086, longitude: -111.86132188132771),
    CLLocationCoordinate2D(latitude: 40.761089555877696, longitude: -111.86128598139933),
    CLLocationCoordinate2D(latitude: 40.761131801589634, longitude: -111.8613431409548),
    CLLocationCoordinate2D(latitude: 40.76108768647692, longitude: -111.86129250219795),
    CLLocationCoordinate2D(latitude: 40.76111424937748, longitude: -111.86132195312433),
    CLLocationCoordinate2D(latitude: 40.76109600632919, longitude: -111.86129713871144),
    CLLocationCoordinate2D(latitude: 40.76111092314084, longitude: -111.86126043514174),
    CLLocationCoordinate2D(latitude: 40.76113224629726, longitude: -111.86130457230745),
    CLLocationCoordinate2D(latitude: 40.761107145883024, longitude: -111.86124575700282),
    CLLocationCoordinate2D(latitude: 40.761125329831906, longitude: -111.86118705489176),
    CLLocationCoordinate2D(latitude: 40.76109891372722, longitude: -111.86118009747368),
    CLLocationCoordinate2D(latitude: 40.76108594822743, longitude: -111.86122491699379),
    CLLocationCoordinate2D(latitude: 40.761048424255584, longitude: -111.86123505738833),
    CLLocationCoordinate2D(latitude: 40.761071925311626, longitude: -111.86122065235742),
    CLLocationCoordinate2D(latitude: 40.76109777559508, longitude: -111.86123075109673),
    CLLocationCoordinate2D(latitude: 40.761058886651014, longitude: -111.8612192540495),
    CLLocationCoordinate2D(latitude: 40.76101831379777, longitude: -111.86117876872544),
    CLLocationCoordinate2D(latitude: 40.76100311320407, longitude: -111.8612237838954),
    CLLocationCoordinate2D(latitude: 40.761047794032976, longitude: -111.86123064532055),
    CLLocationCoordinate2D(latitude: 40.76105722577273, longitude: -111.86122911010462),
    CLLocationCoordinate2D(latitude: 40.7610746142072, longitude: -111.86123611692636),
    CLLocationCoordinate2D(latitude: 40.761048790918444, longitude: -111.8612532170349),
    CLLocationCoordinate2D(latitude: 40.761046190965644, longitude: -111.86128051611934),
    CLLocationCoordinate2D(latitude: 40.76104080391875, longitude: -111.86122663396854),
    CLLocationCoordinate2D(latitude: 40.761082193279705, longitude: -111.8611956743078),
    CLLocationCoordinate2D(latitude: 40.76105122677762, longitude: -111.86122810175591),
    CLLocationCoordinate2D(latitude: 40.76105066613985, longitude: -111.8612499795467),
    CLLocationCoordinate2D(latitude: 40.76103265814844, longitude: -111.86121378803618),
    CLLocationCoordinate2D(latitude: 40.760997559180375, longitude: -111.86123052741819),
    CLLocationCoordinate2D(latitude: 40.76100951033594, longitude: -111.86127800458065),
    CLLocationCoordinate2D(latitude: 40.761033787869266, longitude: -111.86131054799895),
    CLLocationCoordinate2D(latitude: 40.7610116447235, longitude: -111.86135525417926),
    CLLocationCoordinate2D(latitude: 40.761020808548516, longitude: -111.8613164585328),
    CLLocationCoordinate2D(latitude: 40.761056864054595, longitude: -111.86134386121628),
    CLLocationCoordinate2D(latitude: 40.76105579402608, longitude: -111.86138287347924),
    CLLocationCoordinate2D(latitude: 40.76102643227068, longitude: -111.86137474011751),
    CLLocationCoordinate2D(latitude: 40.76099339049354, longitude: -111.86141195632831),
    CLLocationCoordinate2D(latitude: 40.76101211896751, longitude: -111.8614119967483),
    CLLocationCoordinate2D(latitude: 40.76097611869348, longitude: -111.86143649639654),
    CLLocationCoordinate2D(latitude: 40.760949189117305, longitude: -111.86146914017128),
    CLLocationCoordinate2D(latitude: 40.76092877402583, longitude: -111.86150220539976),
    CLLocationCoordinate2D(latitude: 40.76091515989498, longitude: -111.8615175129219),
    CLLocationCoordinate2D(latitude: 40.760924404139615, longitude: -111.86150928229065),
    CLLocationCoordinate2D(latitude: 40.760931956345, longitude: -111.86156776472166),
    CLLocationCoordinate2D(latitude: 40.76090342409683, longitude: -111.86157588363787),
    CLLocationCoordinate2D(latitude: 40.76088615317869, longitude: -111.86153845189638),
    CLLocationCoordinate2D(latitude: 40.760896047968664, longitude: -111.86149575107063),
    CLLocationCoordinate2D(latitude: 40.76090131299733, longitude: -111.86151426448221),
    CLLocationCoordinate2D(latitude: 40.76094582653796, longitude: -111.86153045507065),
    CLLocationCoordinate2D(latitude: 40.76094220187227, longitude: -111.86151422088118),
    CLLocationCoordinate2D(latitude: 40.76096135287049, longitude: -111.86146064228184),
    CLLocationCoordinate2D(latitude: 40.76096984477023, longitude: -111.86148393521869),
    CLLocationCoordinate2D(latitude: 40.76094339664686, longitude: -111.8614374058326),
    CLLocationCoordinate2D(latitude: 40.76097834946595, longitude: -111.86140537219825),
    CLLocationCoordinate2D(latitude: 40.76098698376064, longitude: -111.86138096364245),
    CLLocationCoordinate2D(latitude: 40.76094608075952, longitude: -111.86140958104336),
    CLLocationCoordinate2D(latitude: 40.76097487783456, longitude: -111.86139349977994),
    CLLocationCoordinate2D(latitude: 40.760932690309446, longitude: -111.86144973687264),
    CLLocationCoordinate2D(latitude: 40.76095432316, longitude: -111.86148609352678),
    CLLocationCoordinate2D(latitude: 40.76094554592393, longitude: -111.8614730961344),
    CLLocationCoordinate2D(latitude: 40.76095311245613, longitude: -111.86151924410447),
    CLLocationCoordinate2D(latitude: 40.76095011270781, longitude: -111.86146795068387),
    CLLocationCoordinate2D(latitude: 40.76097983511658, longitude: -111.86144373155743),
    CLLocationCoordinate2D(latitude: 40.7610101031777, longitude: -111.86149816721431),
    CLLocationCoordinate2D(latitude: 40.76099003865618, longitude: -111.86150489248293),
    CLLocationCoordinate2D(latitude: 40.760977679117325, longitude: -111.86147641908188),
    CLLocationCoordinate2D(latitude: 40.760934293090244, longitude: -111.86143303830015),
    CLLocationCoordinate2D(latitude: 40.760935949055, longitude: -111.86139428859282),
    CLLocationCoordinate2D(latitude: 40.760908438973416, longitude: -111.86135440744584),
    CLLocationCoordinate2D(latitude: 40.76091200379627, longitude: -111.86140302064003),
    CLLocationCoordinate2D(latitude: 40.76093322892973, longitude: -111.86139149416432),
    CLLocationCoordinate2D(latitude: 40.76095127997744, longitude: -111.86141185568489),
    CLLocationCoordinate2D(latitude: 40.76093440649762, longitude: -111.86136333782324),
    CLLocationCoordinate2D(latitude: 40.76089367498051, longitude: -111.86138731464055),
    CLLocationCoordinate2D(latitude: 40.760892993713306, longitude: -111.86143054986765),
    CLLocationCoordinate2D(latitude: 40.76092441387988, longitude: -111.86137154166103),
    CLLocationCoordinate2D(latitude: 40.76091386558348, longitude: -111.86134344108156),
    CLLocationCoordinate2D(latitude: 40.76090600126112, longitude: -111.8613000695134),
    CLLocationCoordinate2D(latitude: 40.76086799436471, longitude: -111.86134967578839),
    CLLocationCoordinate2D(latitude: 40.76084711472021, longitude: -111.86131583170845),
    CLLocationCoordinate2D(latitude: 40.76086902366014, longitude: -111.86136784842613),
    CLLocationCoordinate2D(latitude: 40.760878565994766, longitude: -111.8613520918867),
    CLLocationCoordinate2D(latitude: 40.76088177276819, longitude: -111.86130500058147),
    CLLocationCoordinate2D(latitude: 40.76087884317168, longitude: -111.86132763366419),
    CLLocationCoordinate2D(latitude: 40.76084837699384, longitude: -111.86130537102682),
    CLLocationCoordinate2D(latitude: 40.76084099212758, longitude: -111.86124790070458),
    CLLocationCoordinate2D(latitude: 40.760878390075995, longitude: -111.86121566887219),
    CLLocationCoordinate2D(latitude: 40.760888829325694, longitude: -111.86122515472924),
    CLLocationCoordinate2D(latitude: 40.76088007208067, longitude: -111.86123444073361),
    CLLocationCoordinate2D(latitude: 40.76083965225422, longitude: -111.86120551206581),
    CLLocationCoordinate2D(latitude: 40.760870589278, longitude: -111.86119521533455),
    CLLocationCoordinate2D(latitude: 40.760833046068555, longitude: -111.86120101643036),
    CLLocationCoordinate2D(latitude: 40.7608555041423, longitude: -111.86124023511947),
    CLLocationCoordinate2D(latitude: 40.76086517570091, longitude: -111.86125306455881),
    CLLocationCoordinate2D(latitude: 40.76087556026555, longitude: -111.86122165939317),
    CLLocationCoordinate2D(latitude: 40.76084620444283, longitude: -111.86122205165974),
    CLLocationCoordinate2D(latitude: 40.76085743611001, longitude: -111.86124122677268),
    CLLocationCoordinate2D(latitude: 40.76087357165554, longitude: -111.86126125938418),
    CLLocationCoordinate2D(latitude: 40.76086706358758, longitude: -111.8612883808947),
    CLLocationCoordinate2D(latitude: 40.76086164694565, longitude: -111.86131173098947),
    CLLocationCoordinate2D(latitude: 40.760878388501645, longitude: -111.86128947024305),
    CLLocationCoordinate2D(latitude: 40.76090901017323, longitude: -111.86124452576183),
    CLLocationCoordinate2D(latitude: 40.76088234768772, longitude: -111.861200295805),
    CLLocationCoordinate2D(latitude: 40.76085388335178, longitude: -111.86118355110693),
    CLLocationCoordinate2D(latitude: 40.76087966711999, longitude: -111.86123964651048),
    CLLocationCoordinate2D(latitude: 40.760842547044824, longitude: -111.86122740806992),
    CLLocationCoordinate2D(latitude: 40.76084857713266, longitude: -111.86119979374702),
    CLLocationCoordinate2D(latitude: 40.76081299192033, longitude: -111.86123660451426),
    CLLocationCoordinate2D(latitude: 40.76083863044502, longitude: -111.86120735785919),
    CLLocationCoordinate2D(latitude: 40.76086299675058, longitude: -111.86118308577656),
    CLLocationCoordinate2D(latitude: 40.76082470423597, longitude: -111.86123818499817),
    CLLocationCoordinate2D(latitude: 40.76082263952644, longitude: -111.86120596847746),
    CLLocationCoordinate2D(latitude: 40.76079550274876, longitude: -111.86118620578121),
    CLLocationCoordinate2D(latitude: 40.760838589912524, longitude: -111.861226893798),
    CLLocationCoordinate2D(latitude: 40.7608830101087, longitude: -111.86117188182428),
    CLLocationCoordinate2D(latitude: 40.76090329271359, longitude: -111.86122786908716),
    CLLocationCoordinate2D(latitude: 40.76092610064318, longitude: -111.86124576353882),
    CLLocationCoordinate2D(latitude: 40.76090316034897, longitude: -111.8613047293976),
    CLLocationCoordinate2D(latitude: 40.76087254673952, longitude: -111.86129591312486),
    CLLocationCoordinate2D(latitude: 40.7608945250966, longitude: -111.86123895968656),
    CLLocationCoordinate2D(latitude: 40.760852494386384, longitude: -111.86129342437195),
    CLLocationCoordinate2D(latitude: 40.76088556543995, longitude: -111.86127310751749),
    CLLocationCoordinate2D(latitude: 40.760856595723084, longitude: -111.86123789256551),
    CLLocationCoordinate2D(latitude: 40.7608188161441, longitude: -111.86121286485862),
    CLLocationCoordinate2D(latitude: 40.760843807351634, longitude: -111.86121729175285),
    CLLocationCoordinate2D(latitude: 40.760848055831566, longitude: -111.8612584388415),
    CLLocationCoordinate2D(latitude: 40.760853812316114, longitude: -111.86126174502469),
    CLLocationCoordinate2D(latitude: 40.760887686273215, longitude: -111.86126407740363),
    CLLocationCoordinate2D(latitude: 40.76089718480344, longitude: -111.86123009666393),
    CLLocationCoordinate2D(latitude: 40.76087104984023, longitude: -111.86117857245804),
    CLLocationCoordinate2D(latitude: 40.76084936391832, longitude: -111.86121768319435),
    CLLocationCoordinate2D(latitude: 40.760830589624, longitude: -111.8612146072925),
    CLLocationCoordinate2D(latitude: 40.76079364073545, longitude: -111.86124762971384),
    CLLocationCoordinate2D(latitude: 40.760825565914864, longitude: -111.86130335642287),
    CLLocationCoordinate2D(latitude: 40.760861744231406, longitude: -111.86133719195168),
    CLLocationCoordinate2D(latitude: 40.76089249837245, longitude: -111.86131536870435),
    CLLocationCoordinate2D(latitude: 40.76088033839468, longitude: -111.86125837080887),
    CLLocationCoordinate2D(latitude: 40.760877313322354, longitude: -111.8612208385032),
    CLLocationCoordinate2D(latitude: 40.760887001559894, longitude: -111.86121275098236),
    CLLocationCoordinate2D(latitude: 40.76085423033903, longitude: -111.86123115469607),
    CLLocationCoordinate2D(latitude: 40.760846978155115, longitude: -111.86117311074581),
    CLLocationCoordinate2D(latitude: 40.76085090229468, longitude: -111.8611351446593),
    CLLocationCoordinate2D(latitude: 40.76081089873908, longitude: -111.86108558291168),
    CLLocationCoordinate2D(latitude: 40.76082204397351, longitude: -111.86114276005748),
    CLLocationCoordinate2D(latitude: 40.76081737810808, longitude: -111.86115915559255),
    CLLocationCoordinate2D(latitude: 40.76080552726478, longitude: -111.8611130314229),
    CLLocationCoordinate2D(latitude: 40.76081013917923, longitude: -111.86108642127866),
    CLLocationCoordinate2D(latitude: 40.76084607292214, longitude: -111.86110101056255),
    CLLocationCoordinate2D(latitude: 40.760823272568814, longitude: -111.86107459399146),
    CLLocationCoordinate2D(latitude: 40.76083920407443, longitude: -111.86105173199488),
    CLLocationCoordinate2D(latitude: 40.76079699524802, longitude: -111.86105570083124),
    CLLocationCoordinate2D(latitude: 40.76081617091418, longitude: -111.86109250648198),
    CLLocationCoordinate2D(latitude: 40.76085934103644, longitude: -111.86110025941228),
    CLLocationCoordinate2D(latitude: 40.760822147744236, longitude: -111.86106727140512),
    CLLocationCoordinate2D(latitude: 40.760779486368676, longitude: -111.86101089206477),
    CLLocationCoordinate2D(latitude: 40.760755978529794, longitude: -111.86095591976475),
    CLLocationCoordinate2D(latitude: 40.76074248650263, longitude: -111.86093264777404),
    CLLocationCoordinate2D(latitude: 40.76072546349058, longitude: -111.86090009382036),
    CLLocationCoordinate2D(latitude: 40.76075056087407, longitude: -111.86092216955095),
    CLLocationCoordinate2D(latitude: 40.760716439418815, longitude: -111.86091743606741),
    CLLocationCoordinate2D(latitude: 40.76071434072304, longitude: -111.86087714540771),
    CLLocationCoordinate2D(latitude: 40.76074545889217, longitude: -111.8608553752602),
    CLLocationCoordinate2D(latitude: 40.760731089699725, longitude: -111.86080189591975),
    CLLocationCoordinate2D(latitude: 40.76072508734642, longitude: -111.86079674088896),
    CLLocationCoordinate2D(latitude: 40.760737971615804, longitude: -111.86080318241221),
    CLLocationCoordinate2D(latitude: 40.760776796036225, longitude: -111.86085572963268),
    CLLocationCoordinate2D(latitude: 40.76076710557056, longitude: -111.8608960829238),
    CLLocationCoordinate2D(latitude: 40.7607613855802, longitude: -111.86090767212723),
    CLLocationCoordinate2D(latitude: 40.7607758012693, longitude: -111.86088368875924),
    CLLocationCoordinate2D(latitude: 40.760771386580515, longitude: -111.86090209832268),
    CLLocationCoordinate2D(latitude: 40.76076383417314, longitude: -111.86085298253225),
    CLLocationCoordinate2D(latitude: 40.760799886809856, longitude: -111.86080690952983),
    CLLocationCoordinate2D(latitude: 40.76082193659566, longitude: -111.86078599328933),
    CLLocationCoordinate2D(latitude: 40.760804443921586, longitude: -111.86078092023814),
    CLLocationCoordinate2D(latitude: 40.760836563525984, longitude: -111.86079880549327),
    CLLocationCoordinate2D(latitude: 40.7608274685616, longitude: -111.86079781839378),
    CLLocationCoordinate2D(latitude: 40.760832545066705, longitude: -111.86084617602796),
    CLLocationCoordinate2D(latitude: 40.76080453201357, longitude: -111.86087868216542),
    CLLocationCoordinate2D(latitude: 40.76077523007346, longitude: -111.86088921625748),
    CLLocationCoordinate2D(latitude: 40.76081855495028, longitude: -111.86088553755388),
    CLLocationCoordinate2D(latitude: 40.760806426155746, longitude: -111.86088823071313),
    CLLocationCoordinate2D(latitude: 40.76076881922927, longitude: -111.86083103805572),
    CLLocationCoordinate2D(latitude: 40.76073448158817, longitude: -111.86084952143354),
    CLLocationCoordinate2D(latitude: 40.76077420532209, longitude: -111.8608831550961),
    CLLocationCoordinate2D(latitude: 40.7608088914799, longitude: -111.86094073482488),
    CLLocationCoordinate2D(latitude: 40.76080687441603, longitude: -111.86096222080573),
    CLLocationCoordinate2D(latitude: 40.7607702648238, longitude: -111.86095491626101),
    CLLocationCoordinate2D(latitude: 40.76073824942627, longitude: -111.86090835423599),
    CLLocationCoordinate2D(latitude: 40.76075414084063, longitude: -111.86093433006647),
    CLLocationCoordinate2D(latitude: 40.760767997959604, longitude: -111.86091805294257),
    CLLocationCoordinate2D(latitude: 40.760771640751685, longitude: -111.86096810052226),
    CLLocationCoordinate2D(latitude: 40.76077745996014, longitude: -111.86092957546242),
    CLLocationCoordinate2D(latitude: 40.76075512595116, longitude: -111.86087545095761),
    CLLocationCoordinate2D(latitude: 40.760778363837986, longitude: -111.86093433293625),
    CLLocationCoordinate2D(latitude: 40.76076117518403, longitude: -111.86095668037127),
    CLLocationCoordinate2D(latitude: 40.760759469293305, longitude: -111.86098259883674),
    CLLocationCoordinate2D(latitude: 40.76077947763309, longitude: -111.86093429167212),
    CLLocationCoordinate2D(latitude: 40.76077539974335, longitude: -111.86089679974266),
    CLLocationCoordinate2D(latitude: 40.76078291807454, longitude: -111.86086881658353),
    CLLocationCoordinate2D(latitude: 40.76079037125145, longitude: -111.86088944281792),
    CLLocationCoordinate2D(latitude: 40.76077280947459, longitude: -111.8609329912448),
    CLLocationCoordinate2D(latitude: 40.76074321230894, longitude: -111.86096318041237),
    CLLocationCoordinate2D(latitude: 40.760729984632356, longitude: -111.86102106023222),
    CLLocationCoordinate2D(latitude: 40.760726007978086, longitude: -111.86097786052565),
    CLLocationCoordinate2D(latitude: 40.760688626148564, longitude: -111.86093030261368),
    CLLocationCoordinate2D(latitude: 40.76069056507415, longitude: -111.86087301273227),
    CLLocationCoordinate2D(latitude: 40.760649213036544, longitude: -111.86089862825892),
    CLLocationCoordinate2D(latitude: 40.760690405323274, longitude: -111.86086504719692),
    CLLocationCoordinate2D(latitude: 40.76071481149258, longitude: -111.8608949434936),
    CLLocationCoordinate2D(latitude: 40.76072251531063, longitude: -111.86085009340684),
    CLLocationCoordinate2D(latitude: 40.76071915435088, longitude: -111.86090520466895),
    CLLocationCoordinate2D(latitude: 40.760760093253126, longitude: -111.86085228857432),
    CLLocationCoordinate2D(latitude: 40.76078021002816, longitude: -111.86082971603359),
    CLLocationCoordinate2D(latitude: 40.76076481115445, longitude: -111.86078376957255),
    CLLocationCoordinate2D(latitude: 40.76075962012361, longitude: -111.86083657335625),
    CLLocationCoordinate2D(latitude: 40.760767708393516, longitude: -111.86080647750954),
    CLLocationCoordinate2D(latitude: 40.76075148723633, longitude: -111.86086534706128),
    CLLocationCoordinate2D(latitude: 40.76070692022534, longitude: -111.86087484911056),
    CLLocationCoordinate2D(latitude: 40.76074367434268, longitude: -111.86084623160053),
    CLLocationCoordinate2D(latitude: 40.760782715076544, longitude: -111.86088626457119),
    CLLocationCoordinate2D(latitude: 40.76079401608276, longitude: -111.86083036075908),
    CLLocationCoordinate2D(latitude: 40.76075302381738, longitude: -111.86078023992673),
    CLLocationCoordinate2D(latitude: 40.76072340028527, longitude: -111.86073414657758),
    CLLocationCoordinate2D(latitude: 40.76067918282049, longitude: -111.86075217274218),
    CLLocationCoordinate2D(latitude: 40.76065937003696, longitude: -111.86080079798036),
    CLLocationCoordinate2D(latitude: 40.76065708541835, longitude: -111.86084123203534),
    CLLocationCoordinate2D(latitude: 40.76062520029542, longitude: -111.86089302790586),
    CLLocationCoordinate2D(latitude: 40.76065828891651, longitude: -111.86083588878765),
    CLLocationCoordinate2D(latitude: 40.760676737607774, longitude: -111.8608783131685),
    CLLocationCoordinate2D(latitude: 40.76072064885645, longitude: -111.860858014125),
    CLLocationCoordinate2D(latitude: 40.760738850681896, longitude: -111.86089383701328),
    CLLocationCoordinate2D(latitude: 40.76069873432748, longitude: -111.86086794341537),
    CLLocationCoordinate2D(latitude: 40.760688016688874, longitude: -111.86084584118275),
    CLLocationCoordinate2D(latitude: 40.76066262272944, longitude: -111.86087577107763),
    CLLocationCoordinate2D(latitude: 40.76068296538568, longitude: -111.86082016542487),
    CLLocationCoordinate2D(latitude: 40.760683575403974, longitude: -111.86081984774071),
    CLLocationCoordinate2D(latitude: 40.76070017278518, longitude: -111.8608255283279),
    CLLocationCoordinate2D(latitude: 40.76072967041469, longitude: -111.86081446291989),
    CLLocationCoordinate2D(latitude: 40.76072750371083, longitude: -111.8608009780668),
    CLLocationCoordinate2D(latitude: 40.76076529416294, longitude: -111.8607782489633),
    CLLocationCoordinate2D(latitude: 40.76072985855184, longitude: -111.86074275992333),
    CLLocationCoordinate2D(latitude: 40.76068816783449, longitude: -111.86073555688782),
    CLLocationCoordinate2D(latitude: 40.760721395538475, longitude: -111.86077221971456),
    CLLocationCoordinate2D(latitude: 40.76074695442925, longitude: -111.86078228749373),
    CLLocationCoordinate2D(latitude: 40.760716122528464, longitude: -111.86075193496603),
    CLLocationCoordinate2D(latitude: 40.76069270019566, longitude: -111.86079590751157),
    CLLocationCoordinate2D(latitude: 40.760711283099084, longitude: -111.8607596453861),
    CLLocationCoordinate2D(latitude: 40.760676002397325, longitude: -111.86080316749982),
    CLLocationCoordinate2D(latitude: 40.76068781504193, longitude: -111.86077990031133),
    CLLocationCoordinate2D(latitude: 40.76071289377022, longitude: -111.86078362799395),
    CLLocationCoordinate2D(latitude: 40.7607502313192, longitude: -111.8607506903288),
    CLLocationCoordinate2D(latitude: 40.76079230654836, longitude: -111.86071321576681),
    CLLocationCoordinate2D(latitude: 40.760823019631324, longitude: -111.86067437596981),
    CLLocationCoordinate2D(latitude: 40.76081631586981, longitude: -111.86063875740352),
    CLLocationCoordinate2D(latitude: 40.760857802223306, longitude: -111.86068480193892),
    CLLocationCoordinate2D(latitude: 40.76082664116209, longitude: -111.86064157168285),
    CLLocationCoordinate2D(latitude: 40.76085247528932, longitude: -111.86069371151687),
    CLLocationCoordinate2D(latitude: 40.760880357786576, longitude: -111.86067953869662),
    CLLocationCoordinate2D(latitude: 40.760847380627744, longitude: -111.86072881752888),
    CLLocationCoordinate2D(latitude: 40.760871951837515, longitude: -111.86073103393464),
    CLLocationCoordinate2D(latitude: 40.76084154868711, longitude: -111.86078683266435),
    CLLocationCoordinate2D(latitude: 40.760816850683426, longitude: -111.86081911158925),
    CLLocationCoordinate2D(latitude: 40.76081876126811, longitude: -111.86086384521971),
    CLLocationCoordinate2D(latitude: 40.760776242632005, longitude: -111.86088408511944),
    CLLocationCoordinate2D(latitude: 40.76075504673962, longitude: -111.86088451396093),
    CLLocationCoordinate2D(latitude: 40.760710770398106, longitude: -111.86084469526429),
    CLLocationCoordinate2D(latitude: 40.760713838652705, longitude: -111.86083476466956),
    CLLocationCoordinate2D(latitude: 40.76070823287821, longitude: -111.86085818449986),
    CLLocationCoordinate2D(latitude: 40.76071765956396, longitude: -111.86087835621184),
    CLLocationCoordinate2D(latitude: 40.76074064398315, longitude: -111.86091043327896),
    CLLocationCoordinate2D(latitude: 40.760727600369385, longitude: -111.86090915291872),
    CLLocationCoordinate2D(latitude: 40.76075115651441, longitude: -111.86093352005494),
    CLLocationCoordinate2D(latitude: 40.76073984189813, longitude: -111.86093034136049),
    CLLocationCoordinate2D(latitude: 40.76072280621276, longitude: -111.86089930122574),
    CLLocationCoordinate2D(latitude: 40.760713877192174, longitude: -111.86095733620616),
    CLLocationCoordinate2D(latitude: 40.76075355608429, longitude: -111.86093873700622),
    CLLocationCoordinate2D(latitude: 40.760763282673786, longitude: -111.86088848094566),
    CLLocationCoordinate2D(latitude: 40.760781423758566, longitude: -111.8608359657641),
    CLLocationCoordinate2D(latitude: 40.76080070519781, longitude: -111.86085284630289),
    CLLocationCoordinate2D(latitude: 40.76076976161684, longitude: -111.86091134943291),
    CLLocationCoordinate2D(latitude: 40.760746784245896, longitude: -111.8609698214121),
    CLLocationCoordinate2D(latitude: 40.76073788322536, longitude: -111.8610271578107),
    CLLocationCoordinate2D(latitude: 40.76072339932058, longitude: -111.8610652208417),
    CLLocationCoordinate2D(latitude: 40.760711378071235, longitude: -111.86107992859633),
    CLLocationCoordinate2D(latitude: 40.760751405418574, longitude: -111.86103652060038),
    CLLocationCoordinate2D(latitude: 40.760760698547394, longitude: -111.86099566176516),
    CLLocationCoordinate2D(latitude: 40.760735356116065, longitude: -111.8610488549267),
    CLLocationCoordinate2D(latitude: 40.760725136486876, longitude: -111.86103778129142),
    CLLocationCoordinate2D(latitude: 40.760702574789, longitude: -111.86104307846166),
    CLLocationCoordinate2D(latitude: 40.76068309158844, longitude: -111.86100535086419),
    CLLocationCoordinate2D(latitude: 40.76064835922525, longitude: -111.86099704913747),
    CLLocationCoordinate2D(latitude: 40.7606322799191, longitude: -111.86104394891844),
    CLLocationCoordinate2D(latitude: 40.76062630710575, longitude: -111.86102076626939),
    CLLocationCoordinate2D(latitude: 40.76065945418376, longitude: -111.86102934471604),
    CLLocationCoordinate2D(latitude: 40.76066557557308, longitude: -111.86103890346527),
    CLLocationCoordinate2D(latitude: 40.760652782158644, longitude: -111.86102844767798),
    CLLocationCoordinate2D(latitude: 40.760673433855864, longitude: -111.86099245658528),
    CLLocationCoordinate2D(latitude: 40.760638690921176, longitude: -111.86095565066057),
    CLLocationCoordinate2D(latitude: 40.760676408219744, longitude: -111.86094312284925),
    CLLocationCoordinate2D(latitude: 40.76067981740191, longitude: -111.86093788251908),
    CLLocationCoordinate2D(latitude: 40.76068981561271, longitude: -111.86096979846693),
    CLLocationCoordinate2D(latitude: 40.76073120257003, longitude: -111.86096531781773),
    CLLocationCoordinate2D(latitude: 40.76069842708013, longitude: -111.86096513534855),
    CLLocationCoordinate2D(latitude: 40.7606875616693, longitude: -111.86098607765891),
    CLLocationCoordinate2D(latitude: 40.760658441275915, longitude: -111.86095555161837),
    CLLocationCoordinate2D(latitude: 40.760635031950244, longitude: -111.86098284720256),
    CLLocationCoordinate2D(latitude: 40.76063813854548, longitude: -111.86096885193676),
    CLLocationCoordinate2D(latitude: 40.76064060583137, longitude: -111.86094262757645),
    CLLocationCoordinate2D(latitude: 40.760622247343065, longitude: -111.86092592557004),
    CLLocationCoordinate2D(latitude: 40.76062620511251, longitude: -111.860891428467),
    CLLocationCoordinate2D(latitude: 40.7606653547496, longitude: -111.86086815067618),
    CLLocationCoordinate2D(latitude: 40.76065487478671, longitude: -111.86086179621121),
    CLLocationCoordinate2D(latitude: 40.760610993179704, longitude: -111.86087754381562),
    CLLocationCoordinate2D(latitude: 40.760576798199914, longitude: -111.86091748094054),
    CLLocationCoordinate2D(latitude: 40.76059347467695, longitude: -111.86097144194709),
    CLLocationCoordinate2D(latitude: 40.76059961201994, longitude: -111.86101229298762),
    CLLocationCoordinate2D(latitude: 40.76061976040652, longitude: -111.86106312078336),
    CLLocationCoordinate2D(latitude: 40.760632024004, longitude: -111.86105172131057),
    CLLocationCoordinate2D(latitude: 40.76059082858047, longitude: -111.8610578286861),
    CLLocationCoordinate2D(latitude: 40.76060622286969, longitude: -111.8610181421869),
    CLLocationCoordinate2D(latitude: 40.76056566591384, longitude: -111.86099260971736),
    CLLocationCoordinate2D(latitude: 40.76057019895066, longitude: -111.8610451091494),
    CLLocationCoordinate2D(latitude: 40.7605260425871, longitude: -111.86107140643207),
    CLLocationCoordinate2D(latitude: 40.760532148859944, longitude: -111.86103500398399),
    CLLocationCoordinate2D(latitude: 40.76057155391677, longitude: -111.86102648519342),
    CLLocationCoordinate2D(latitude: 40.76059530631271, longitude: -111.86101197041769),
    CLLocationCoordinate2D(latitude: 40.76056812734868, longitude: -111.86100874685071),
    CLLocationCoordinate2D(latitude: 40.76053381151191, longitude: -111.86098985844373),
    CLLocationCoordinate2D(latitude: 40.76050743872371, longitude: -111.86097007731789),
    CLLocationCoordinate2D(latitude: 40.76049971971289, longitude: -111.86098570091814),
    CLLocationCoordinate2D(latitude: 40.76053762645362, longitude: -111.86102454882968),
    CLLocationCoordinate2D(latitude: 40.760574626255234, longitude: -111.860967907964),
    CLLocationCoordinate2D(latitude: 40.76061176313461, longitude: -111.86102603216315),
    CLLocationCoordinate2D(latitude: 40.7606389062755, longitude: -111.86099556039349),
    CLLocationCoordinate2D(latitude: 40.76060965499822, longitude: -111.86101429734708),
    CLLocationCoordinate2D(latitude: 40.7606478289488, longitude: -111.86101707289404),
    CLLocationCoordinate2D(latitude: 40.76062942639537, longitude: -111.86098940722941),
    CLLocationCoordinate2D(latitude: 40.76060227064386, longitude: -111.86099025043823),
    CLLocationCoordinate2D(latitude: 40.7606445955071, longitude: -111.86098989583759),
    CLLocationCoordinate2D(latitude: 40.76062886247262, longitude: -111.86095482011157),
    CLLocationCoordinate2D(latitude: 40.760658888848894, longitude: -111.86098439261194),
    CLLocationCoordinate2D(latitude: 40.76063989169043, longitude: -111.86092877073592),
    CLLocationCoordinate2D(latitude: 40.76066758753535, longitude: -111.8609685328305),
    CLLocationCoordinate2D(latitude: 40.760649241709984, longitude: -111.86098141185154),
    CLLocationCoordinate2D(latitude: 40.7606058222188, longitude: -111.86103756510077),
    CLLocationCoordinate2D(latitude: 40.760577640856276, longitude: -111.86105988771055),
    CLLocationCoordinate2D(latitude: 40.76059414350624, longitude: -111.86100650534472),
    CLLocationCoordinate2D(latitude: 40.76063040447282, longitude: -111.86103028380045),
    CLLocationCoordinate2D(latitude: 40.76066054797526, longitude: -111.86102123804534),
    CLLocationCoordinate2D(latitude: 40.760701369625004, longitude: -111.86104046441234),
    CLLocationCoordinate2D(latitude: 40.76068180953794, longitude: -111.8610746498369),
    CLLocationCoordinate2D(latitude: 40.760724948408736, longitude: -111.86110447615943),
    CLLocationCoordinate2D(latitude: 40.7607616692263, longitude: -111.86111628766876),
    CLLocationCoordinate2D(latitude: 40.76078385307048, longitude: -111.86111807575575),
    CLLocationCoordinate2D(latitude: 40.76082832408227, longitude: -111.86112850178208),
    CLLocationCoordinate2D(latitude: 40.760797118096285, longitude: -111.86111176638336),
    CLLocationCoordinate2D(latitude: 40.76075534354136, longitude: -111.86111524109229),
    CLLocationCoordinate2D(latitude: 40.7607378190857, longitude: -111.8611673012903),
    CLLocationCoordinate2D(latitude: 40.76071294829726, longitude: -111.86119258347424),
    CLLocationCoordinate2D(latitude: 40.760755891027095, longitude: -111.86116719618323),
    CLLocationCoordinate2D(latitude: 40.76073587218933, longitude: -111.8611563329333),
    CLLocationCoordinate2D(latitude: 40.760779570030685, longitude: -111.86118454934116),
    CLLocationCoordinate2D(latitude: 40.76073945887891, longitude: -111.86121328018977),
    CLLocationCoordinate2D(latitude: 40.7607679077548, longitude: -111.8612617465417),
    CLLocationCoordinate2D(latitude: 40.76080836382068, longitude: -111.86129789974164),
    CLLocationCoordinate2D(latitude: 40.760817748392846, longitude: -111.86131286814158),
    CLLocationCoordinate2D(latitude: 40.76086085916753, longitude: -111.86136567598393),
    CLLocationCoordinate2D(latitude: 40.760817868814556, longitude: -111.86134475761332),
    CLLocationCoordinate2D(latitude: 40.76078012522902, longitude: -111.86128700273822),
    CLLocationCoordinate2D(latitude: 40.760812833915445, longitude: -111.86133878615037),
    CLLocationCoordinate2D(latitude: 40.76083581568464, longitude: -111.86130992415745),
    CLLocationCoordinate2D(latitude: 40.76080810364522, longitude: -111.86125881896544),
    CLLocationCoordinate2D(latitude: 40.7608029294691, longitude: -111.861244782261),
    CLLocationCoordinate2D(latitude: 40.76084057466855, longitude: -111.86123913462494),
    CLLocationCoordinate2D(latitude: 40.76080798367609, longitude: -111.8612131391989),
    CLLocationCoordinate2D(latitude: 40.76080055607363, longitude: -111.86118164985825),
    CLLocationCoordinate2D(latitude: 40.76081322952355, longitude: -111.86118063288558),
    CLLocationCoordinate2D(latitude: 40.76082694519893, longitude: -111.86118166172939),
    CLLocationCoordinate2D(latitude: 40.76083358338573, longitude: -111.86114276598232),
    CLLocationCoordinate2D(latitude: 40.760796849831436, longitude: -111.86115609854757),
    CLLocationCoordinate2D(latitude: 40.760824175693216, longitude: -111.86112575286793),
    CLLocationCoordinate2D(latitude: 40.76083623888101, longitude: -111.86112320916011),
    CLLocationCoordinate2D(latitude: 40.760821260403304, longitude: -111.86116397150354),
    CLLocationCoordinate2D(latitude: 40.76078040083973, longitude: -111.86117434259333),
    CLLocationCoordinate2D(latitude: 40.76079933635042, longitude: -111.86117983324075),
    CLLocationCoordinate2D(latitude: 40.760803210822424, longitude: -111.86121991681739),
    CLLocationCoordinate2D(latitude: 40.76079135148352, longitude: -111.86123094496571),
    CLLocationCoordinate2D(latitude: 40.76074983416284, longitude: -111.86121371297675),
    CLLocationCoordinate2D(latitude: 40.76077962130132, longitude: -111.86119656888137),
    CLLocationCoordinate2D(latitude: 40.760817362414215, longitude: -111.86119486237531),
    CLLocationCoordinate2D(latitude: 40.76085021039824, longitude: -111.8611881427646),
    CLLocationCoordinate2D(latitude: 40.7608666775743, longitude: -111.86121715421496),
    CLLocationCoordinate2D(latitude: 40.760842986840366, longitude: -111.86123207318124),
    CLLocationCoordinate2D(latitude: 40.76088682856804, longitude: -111.86123734905382),
    CLLocationCoordinate2D(latitude: 40.760885566035356, longitude: -111.86128769524737),
    CLLocationCoordinate2D(latitude: 40.760893404594135, longitude: -111.86127836541058),
    CLLocationCoordinate2D(latitude: 40.76089513804885, longitude: -111.86126135112423),
    CLLocationCoordinate2D(latitude: 40.76093025433617, longitude: -111.8612434975024),
    CLLocationCoordinate2D(latitude: 40.76095372356834, longitude: -111.86124243289831),
    CLLocationCoordinate2D(latitude: 40.760916439273636, longitude: -111.86126709681261),
    CLLocationCoordinate2D(latitude: 40.76088319431254, longitude: -111.8612329401054),
    CLLocationCoordinate2D(latitude: 40.760918527376944, longitude: -111.8612827972188),
    CLLocationCoordinate2D(latitude: 40.76091730628557, longitude: -111.86130065952104),
    CLLocationCoordinate2D(latitude: 40.760950968486526, longitude: -111.86127932010137),
    CLLocationCoordinate2D(latitude: 40.760994879712, longitude: -111.8612380949419),
    CLLocationCoordinate2D(latitude: 40.761007393350376, longitude: -111.86119043166838),
    CLLocationCoordinate2D(latitude: 40.76098085736008, longitude: -111.86116823539525),
    CLLocationCoordinate2D(latitude: 40.760945084228894, longitude: -111.86122577936507),
    CLLocationCoordinate2D(latitude: 40.76097059930559, longitude: -111.8612422327178),
    CLLocationCoordinate2D(latitude: 40.76099440493724, longitude: -111.86129246840282),
    CLLocationCoordinate2D(latitude: 40.761019747450774, longitude: -111.86126442439945),
    CLLocationCoordinate2D(latitude: 40.76105859751585, longitude: -111.86124030170963),
    CLLocationCoordinate2D(latitude: 40.761091928120926, longitude: -111.86124968950898),
    CLLocationCoordinate2D(latitude: 40.761072107115325, longitude: -111.8612792887467),
    CLLocationCoordinate2D(latitude: 40.761061111902215, longitude: -111.86126090360395),
    CLLocationCoordinate2D(latitude: 40.76108904049605, longitude: -111.86120601674413),
    CLLocationCoordinate2D(latitude: 40.76104465718105, longitude: -111.86119586208157),
    CLLocationCoordinate2D(latitude: 40.76102702346327, longitude: -111.8612350617188),
    CLLocationCoordinate2D(latitude: 40.76107086152191, longitude: -111.86120929946753),
    CLLocationCoordinate2D(latitude: 40.761026790981205, longitude: -111.86124438077063),
    CLLocationCoordinate2D(latitude: 40.76098705270814, longitude: -111.8612626289377),
    CLLocationCoordinate2D(latitude: 40.76096615424155, longitude: -111.86121567984188),
    CLLocationCoordinate2D(latitude: 40.76096296842218, longitude: -111.86120862442806),
    CLLocationCoordinate2D(latitude: 40.76094872835246, longitude: -111.86121027610248),
    CLLocationCoordinate2D(latitude: 40.7609216693947, longitude: -111.86115574068158),
    CLLocationCoordinate2D(latitude: 40.760927625692595, longitude: -111.86113449961107),
    CLLocationCoordinate2D(latitude: 40.76095340455416, longitude: -111.86111078669022),
    CLLocationCoordinate2D(latitude: 40.76091642236306, longitude: -111.8611416424876),
    CLLocationCoordinate2D(latitude: 40.7609431562607, longitude: -111.8611727479906),
    CLLocationCoordinate2D(latitude: 40.76094559273148, longitude: -111.86123029121977),
    CLLocationCoordinate2D(latitude: 40.76092803532096, longitude: -111.86121476594519),
    CLLocationCoordinate2D(latitude: 40.760931867252495, longitude: -111.86127244377533),
    CLLocationCoordinate2D(latitude: 40.76089992032241, longitude: -111.86131954323037),
    CLLocationCoordinate2D(latitude: 40.760872057055074, longitude: -111.8613385669739),
    CLLocationCoordinate2D(latitude: 40.760840998629895, longitude: -111.86136414556361),
    CLLocationCoordinate2D(latitude: 40.76086637815238, longitude: -111.8613688705696),
    CLLocationCoordinate2D(latitude: 40.760855149321344, longitude: -111.86136064404131),
    CLLocationCoordinate2D(latitude: 40.760863556975174, longitude: -111.86140459524238),
    CLLocationCoordinate2D(latitude: 40.76083321063545, longitude: -111.86142122815666),
    CLLocationCoordinate2D(latitude: 40.76083141719932, longitude: -111.86139104671692),
    CLLocationCoordinate2D(latitude: 40.76084468619139, longitude: -111.86140672790175),
    CLLocationCoordinate2D(latitude: 40.760888057758464, longitude: -111.8614570641234),
    CLLocationCoordinate2D(latitude: 40.76084405537545, longitude: -111.86150115875908),
    CLLocationCoordinate2D(latitude: 40.76086824908544, longitude: -111.8615407059931),
    CLLocationCoordinate2D(latitude: 40.760879715837504, longitude: -111.86158274714839),
    CLLocationCoordinate2D(latitude: 40.76091682745587, longitude: -111.86163553586225),
    CLLocationCoordinate2D(latitude: 40.76091985728757, longitude: -111.86164988796097),
    CLLocationCoordinate2D(latitude: 40.76090244940746, longitude: -111.86160865564052),
    CLLocationCoordinate2D(latitude: 40.76086254906348, longitude: -111.8616242605292),
    CLLocationCoordinate2D(latitude: 40.760843047327526, longitude: -111.8616001941489),
    CLLocationCoordinate2D(latitude: 40.760798407808146, longitude: -111.86160381210591),
    CLLocationCoordinate2D(latitude: 40.76079305002738, longitude: -111.86165011545829),
    CLLocationCoordinate2D(latitude: 40.76075200083989, longitude: -111.86169716161417),
    CLLocationCoordinate2D(latitude: 40.76071901919927, longitude: -111.86173020072388),
    CLLocationCoordinate2D(latitude: 40.76067510932406, longitude: -111.86168178909725),
    CLLocationCoordinate2D(latitude: 40.76064590601736, longitude: -111.8616581360757),
    CLLocationCoordinate2D(latitude: 40.760645525472896, longitude: -111.86161628568937),
    CLLocationCoordinate2D(latitude: 40.76066807822273, longitude: -111.86164376878659),
    CLLocationCoordinate2D(latitude: 40.76066995249285, longitude: -111.8616020105208),
    CLLocationCoordinate2D(latitude: 40.76063778722652, longitude: -111.86155165174893),
    CLLocationCoordinate2D(latitude: 40.76061413902195, longitude: -111.86152492369575),
    CLLocationCoordinate2D(latitude: 40.760606011752834, longitude: -111.86151478857605),
    CLLocationCoordinate2D(latitude: 40.76064396143622, longitude: -111.86155972882145),
    CLLocationCoordinate2D(latitude: 40.76064091127712, longitude: -111.86154437388149),
    CLLocationCoordinate2D(latitude: 40.76063498975679, longitude: -111.86155875684493),
]

let WORKOUTS = [
    Workout(
        type: .soccer,
        workout: HKWorkout(activityType: .other, start: Date(), end: Date())
    )
]
