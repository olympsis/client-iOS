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
let VENUES: [Venue] = [
    Venue(id: UUID().uuidString, name: "Richard Building Fields", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The Richard Building fields is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["field-images/22aa23f7-5fb5-4c2e-b4fb-3a2943d492fc.jpg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States", bookingURL: "https://www.olympsis.com/signin", requiresBooking: true),
    Venue(id: UUID().uuidString, name: "Indoor Practice Facility", owner: Ownership(name: "Brigham Young University", type: "private"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Provo", state: "UT", country: "United States of America"),
    Venue(id: UUID().uuidString, name: "11th Ave Park", owner: Ownership(name: "Salt Lake City", type: "public"), description: "The 11th ave park is a newly built park in the avenues. It is a multi-purposed park, featuring basketball, volleyball and tennis courts. It also features a walking trail and a drinking fountain.", sports: ["soccer", "pickleball"], images: ["feed-images/B7671402-A924-4C92-966D-7531B1C6D71F.jpeg"], location: GeoJSON(type: "point", coordinates: [-111.655317, 40.24948]), city: "Salt Lake City", state: "UT", country: "United States of America"),

    // Riverside Park Tennis Courts — fully populated sample for the
    // new (Go-aligned) `Venue` initializer. Exercises every rich
    // field the legacy entries above leave unset: seasonal hours,
    // bookable units with `MultiPolygon` footprints, transit lines,
    // features, access flags, and amenities. The supporting data
    // (court footprints, season blocks, helper builders) lives in
    // the private section at the bottom of this file so the array
    // entry itself stays scannable.
    Venue(
        id: _riversideVenueID,
        ownerID: "65cf1b4c7a8b9c0d1e2f3a4b",
        name: "Riverside Park Tennis Courts",
        description: "10 Red Clay tennis courts in Manhattan, NYC. The only outdoor red clay public courts in NYC. Managed by Riverside Tennis Association (RCTA). Call hotline (212) 978-0277 for court conditions - clay dries slower after rain. Free parking lot available. Membership available with benefits. Free Saturday night concerts in summer. Junior and adult programs, summer camp, private lessons. Partner list and WhatsApp chat for members",
        availability: Availability(
            regularHours: _weekHours(open: "07:00", close: "20:00"),
            seasonalHours: _riversideSeasonalHours
        ),
        sports: ["tennis"],
        media: ["venue-media/80f804ae-46c9-45f1-842a-9941f80e0d1e.jpg"],
        url: "https://riversidetennis.org/",
        address: "Riverside Drive and W. 96th St., New York, NY",
        location: GeoJSON(type: "Point", coordinates: [-73.976965, 40.796841]),
        locality: "New York",
        subLocality: "Manhattan",
        administrativeArea: "NY",
        countryCode: "US",
        timezone: "America/New_York",
        units: _riversideCourts,
        transitLines: _riversideTransitLines,
        features: VenueFeatures(indoor: false, accessible: false, illuminated: false),
        access: VenueAccess(requiresPermit: true, requiresBooking: true, requiresMembership: false),
        capabilities: VenueCapabilities(supportsQueue: false, supportsWaitTimes: false),
        amenities: [
            "parking",
            "lessons",
            "online_reservations",
            "membership",
            "junior_programs",
            "adult_programs",
            "summer_camp",
            "private_lessons"
        ]
    ),

    // Riverbank State Park — 4 hard outdoor courts run by NY State
    // Parks along the Hudson in Upper Manhattan. Differences from
    // Riverside Park above: a single open-season block (no
    // year-round `regularHours`), `Polygon` (not `MultiPolygon`)
    // unit footprints, per-unit availability that mirrors the
    // venue's, hard green surface, illuminated, permit-only (no
    // booking gate), no amenities list. The supporting data lives
    // in its own helper section below.
    Venue(
        id: _riverbankVenueID,
        ownerID: "65cf1b4c7a8b9c0d1e2f3a4b",
        name: "Riverbank State Park",
        description: "4 hard outdoor tennis courts at Riverbank State Park along the Hudson River in Upper Manhattan. NY State permit required. Lights for night play. Open April through Thanksgiving Day.",
        availability: Availability(
            // Empty regular hours — the venue only has a seasonal
            // schedule, so the resolver should fall through to
            // `seasonalHours` year-round and return "closed" outside
            // the open-season window.
            regularHours: [],
            seasonalHours: [_riverbankOpenSeason]
        ),
        sports: ["tennis"],
        media: ["venue-media/62dc2dfd-5403-4c8f-93fd-861075ce6fd3.jpg"],
        url: "",
        address: "679 Riverside Dr, New York, NY 10031",
        location: GeoJSON(type: "Point", coordinates: [-73.956932, 40.825218]),
        locality: "New York",
        subLocality: "Manhattan",
        administrativeArea: "NY",
        countryCode: "US",
        timezone: "America/New_York",
        units: _riverbankCourts,
        transitLines: _riverbankTransitLines,
        features: VenueFeatures(indoor: false, accessible: false, illuminated: true),
        access: VenueAccess(requiresPermit: true, requiresBooking: false, requiresMembership: false),
        capabilities: VenueCapabilities(supportsQueue: false, supportsWaitTimes: false),
        amenities: []
    )
]

// MARK: - Riverside Park helpers
//
// Pulled out of the `VENUES` array literal so the 10-court footprint
// table and the seasonal-hours block don't drown the rest of the
// venues. Everything below is intentionally `private` and `_`-prefixed
// — these are file-local helpers, not part of the temp-data API.

/// Stable id reused on the venue and every court so the unit ←→ venue
/// back-reference matches the JSON we modeled this from.
private let _riversideVenueID = "69ec3d0dbd2656fa514ccc36"

/// Build a full Mon→Sun weekly schedule with a single open / close
/// window. Venue-agnostic — used by every NYC tennis venue below for
/// both `regularHours` and the per-day schedule inside each
/// `SeasonalHours` block. (The seed venues all run the same window
/// across all seven days; if a venue ever needs per-day variation
/// we'll add a separate builder instead of overloading this one.)
private func _weekHours(open: String, close: String) -> [TimeSlot] {
    ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        .map { TimeSlot(day: $0, open: open, close: close) }
}

/// Seasonal-hours table. Spring / summer / fall narrow the
/// regular-hours window as daylight shrinks; the off-season block
/// (Dec 1 → Apr 14) is closed entirely, which the
/// `closed: true` + empty `hours` pair models per the Go schema.
private let _riversideSeasonalHours: [SeasonalHours] = [
    SeasonalHours(name: "april", startDay: "04-15", endDay: "04-30", hours: _weekHours(open: "07:00", close: "19:00")),
    SeasonalHours(name: "peak_summer", startDay: "05-01", endDay: "08-31", hours: _weekHours(open: "07:00", close: "20:00")),
    SeasonalHours(name: "september", startDay: "09-01", endDay: "09-30", hours: _weekHours(open: "07:00", close: "19:00")),
    SeasonalHours(name: "october", startDay: "10-01", endDay: "10-31", hours: _weekHours(open: "07:00", close: "18:00")),
    SeasonalHours(name: "november", startDay: "11-01", endDay: "11-30", hours: _weekHours(open: "07:00", close: "16:00")),
    SeasonalHours(name: "off_season", startDay: "12-01", endDay: "04-14", hours: [], closed: true)
]

/// Build a court `VenueUnit` from a single closed ring. The JSON
/// stores each court as a `MultiPolygon` with one polygon and one
/// ring, so we wrap the ring in `[[ring]]` to match the
/// `[[[[Double]]]]` shape `GeoJSON` expects.
private func _riversideCourt(id: String, name: String, ring: [[Double]]) -> VenueUnit {
    VenueUnit(
        id: id,
        venueID: _riversideVenueID,
        name: name,
        unitType: "court",
        location: GeoJSON(type: "MultiPolygon", multiPolygon: [[ring]]),
        surface: "clay",
        surfaceColor: "#b85b3a",
        sports: ["tennis"]
    )
}

/// Ten red-clay outdoor courts. Footprints come straight from the
/// JSON. Each ring is closed (first point == last point) per GeoJSON
/// spec; coordinates are `[lng, lat]`.
private let _riversideCourts: [VenueUnit] = [
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc37", name: "Court 1", ring: [
        [-73.97734363048146, 40.796672894009966],
        [-73.9772286034525, 40.796626268684136],
        [-73.9770957622793, 40.79681387947885],
        [-73.97721019704865, 40.7968605678537],
        [-73.97734363048146, 40.796672894009966]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc38", name: "Court 2", ring: [
        [-73.97681627672914, 40.797205858816405],
        [-73.97668663644443, 40.79739601637949],
        [-73.97680114577535, 40.79744161196462],
        [-73.97693476961842, 40.79725484455182],
        [-73.97681627672914, 40.797205858816405]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc39", name: "Court 3", ring: [
        [-73.97692332239593, 40.796743984321594],
        [-73.97705613377526, 40.79655443584218],
        [-73.97694093260863, 40.79650884576832],
        [-73.97680835132836, 40.79669707763215],
        [-73.97692332239593, 40.796743984321594]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc3a", name: "Court 4", ring: [
        [-73.97688142395758, 40.79685736954343],
        [-73.97674568098614, 40.79704389604511],
        [-73.97686083890268, 40.79709005991968],
        [-73.97699515129716, 40.79690390040218],
        [-73.97688142395758, 40.79685736954343]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc3b", name: "Court 5", ring: [
        [-73.97741336443441, 40.79657007333409],
        [-73.9775477194943, 40.79638322428403],
        [-73.97743355080189, 40.79633633277978],
        [-73.97729967289345, 40.79652362303701],
        [-73.97741336443441, 40.79657007333409]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc3c", name: "Court 6", ring: [
        [-73.97706574950837, 40.796802070662274],
        [-73.97719996165901, 40.7966146123574],
        [-73.97708519343263, 40.796567156678464],
        [-73.97695249383608, 40.79675571916618],
        [-73.97706574950837, 40.796802070662274]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc3d", name: "Court 7", ring: [
        [-73.97678994507585, 40.797195132169115],
        [-73.97667731672676, 40.797149409080646],
        [-73.9765422819893, 40.79733701877871],
        [-73.97665740448598, 40.79738386002275],
        [-73.97678994507585, 40.797195132169115]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc3e", name: "Court 8", ring: [
        [-73.97673851874822, 40.796797636765675],
        [-73.97660485328699, 40.7969858618648],
        [-73.97671832941182, 40.7970324883977],
        [-73.97685296132448, 40.79684492703069],
        [-73.97673851874822, 40.796797636765675]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc3f", name: "Court 9", ring: [
        [-73.97726957534945, 40.79651050402919],
        [-73.97740475882408, 40.796324049726174],
        [-73.97728835123964, 40.796275927556124],
        [-73.97715657238146, 40.7964642698462],
        [-73.97726957534945, 40.79651050402919]
    ]),
    _riversideCourt(id: "69ec3d0dbd2656fa514ccc40", name: "Court 10", ring: [
        [-73.97702226155808, 40.79691409226151],
        [-73.97689177908838, 40.79710327735638],
        [-73.97700566355584, 40.797148974371694],
        [-73.97713755897041, 40.796961113164066],
        [-73.97702226155808, 40.79691409226151]
    ])
]

/// MTA subway lines that serve the courts. The 1 and 3 share the red
/// `#EE352E` line color — both are listed because they stop at
/// different stations within walking distance.
private let _riversideTransitLines: [TransitLine] = [
    TransitLine(id: "69ec18f459ebae87fc4151e8", type: "subway", name: "1", system: "MTA", color: "#EE352E", iconURL: "", locality: "New York", administrativeArea: "NY", countryCode: "US"),
    TransitLine(id: "69ec18f459ebae87fc4151ea", type: "subway", name: "3", system: "MTA", color: "#EE352E", iconURL: "", locality: "New York", administrativeArea: "NY", countryCode: "US")
]

// MARK: - Riverbank State Park helpers
//
// Pulled out of the `VENUES` array literal so the 4-court footprint
// table and the seasonal block stay readable. Same conventions as the
// Riverside Park helpers above: `private`, `_`-prefixed file-locals
// that exist solely to keep the array entry scannable.

/// Stable id reused on the venue and every court so the unit ←→ venue
/// back-reference matches the JSON we modeled this from.
private let _riverbankVenueID = "69ed7b327e0ed0cebd05cbaa"

/// The single open-season block (Apr 1 – Nov 30, 7am–10pm every day).
/// Both the venue's `availability.seasonalHours` and every court's
/// per-unit availability reference this same value, so the resolver
/// answers consistently whether you ask the venue or a specific
/// court. Outside the window the courts are closed entirely — modeled
/// by *absence* of any other seasonal block (no year-round
/// `regularHours` and no off-season entry).
private let _riverbankOpenSeason = SeasonalHours(
    name: "open_season",
    startDay: "04-01",
    endDay: "11-30",
    hours: _weekHours(open: "07:00", close: "22:00")
)

/// Availability attached to each individual `VenueUnit` below. Mirrors
/// the venue's schedule rather than deriving from it because the Go
/// schema stores them separately — keeping the iOS seed data parallel
/// to the JSON shape makes the round-trip Codable test trivial.
private let _riverbankCourtAvailability = Availability(seasonalHours: [_riverbankOpenSeason])

/// Build a `Polygon`-shaped court (Riverbank uses single-ring
/// `Polygon` units, unlike Riverside's `MultiPolygon`). Surface
/// metadata + per-unit availability are baked in so the call sites
/// only have to vary the id, name, and ring coordinates.
private func _riverbankCourt(id: String, name: String, ring: [[Double]]) -> VenueUnit {
    VenueUnit(
        id: id,
        venueID: _riverbankVenueID,
        name: name,
        unitType: "court",
        // Polygon coordinates are `[[[Double]]]` — array of rings,
        // each ring a list of points. There's only one outer ring
        // here, so we wrap the supplied ring in `[ring]`.
        location: GeoJSON(type: "Polygon", polygon: [ring]),
        surface: "hard",
        surfaceColor: "#0A6C3B",
        sports: ["tennis"],
        availability: _riverbankCourtAvailability
    )
}

/// Four hard outdoor courts laid out along the Hudson-side of the
/// park. Rings are closed (first == last point) per GeoJSON spec;
/// coordinates are `[lng, lat]`.
private let _riverbankCourts: [VenueUnit] = [
    _riverbankCourt(id: "69ed7b327e0ed0cebd05cbab", name: "Court 1", ring: [
        [-73.95802, 40.82399],
        [-73.95815, 40.8238],
        [-73.95803, 40.82375],
        [-73.9579, 40.82394],
        [-73.95802, 40.82399]
    ]),
    _riverbankCourt(id: "69ed7b327e0ed0cebd05cbac", name: "Court 2", ring: [
        [-73.95786, 40.82393],
        [-73.95799, 40.82374],
        [-73.95787, 40.82369],
        [-73.95774, 40.82388],
        [-73.95786, 40.82393]
    ]),
    _riverbankCourt(id: "69ed7b327e0ed0cebd05cbad", name: "Court 3", ring: [
        [-73.9582, 40.82371],
        [-73.95833, 40.82352],
        [-73.95821, 40.82347],
        [-73.95809, 40.82366],
        [-73.9582, 40.82371]
    ]),
    _riverbankCourt(id: "69ed7b327e0ed0cebd05cbae", name: "Court 4", ring: [
        [-73.95805, 40.82365],
        [-73.95818, 40.82345],
        [-73.95806, 40.82341],
        [-73.95793, 40.8236],
        [-73.95805, 40.82365]
    ])
]

/// MTA subway line that serves the park (the 1 train stops at
/// 145 St – City College, a short walk west to the courts).
private let _riverbankTransitLines: [TransitLine] = [
    TransitLine(id: "69ec18f459ebae87fc4151e8", type: "subway", name: "1", system: "MTA", color: "#EE352E", iconURL: "", locality: "New York", administrativeArea: "NY", countryCode: "US")
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
            ),
            Participant(
                id: UUID().uuidString,
                user: USER_SNIPPETS[1],
                status: .Yes,
                isAnonymous: false,
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
