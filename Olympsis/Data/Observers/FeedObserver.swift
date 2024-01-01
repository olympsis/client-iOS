//
//  FeedObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import Foundation

class FeedObserver: ObservableObject{
    @Published var announcements = [Announcement(id: "0", image: "feed-images/89b037d3-e4d6-4e65-86a4-27ef09983489.jpg"), Announcement(id: "1", image: "feed-images/072bb74c-bebe-449d-9d1f-efe26b974081.jpg")]
}
