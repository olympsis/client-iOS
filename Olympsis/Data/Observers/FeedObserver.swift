//
//  FeedObserver.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/23/22.
//

import Foundation

class FeedObserver: ObservableObject{
    @Published var announcements = [Announcement(id: "0", image: "https://storage.googleapis.com/olympsis-1/announcements/Welcome%20Image%20-%20Soccer.jpg"), Announcement(id: "1", image: "https://storage.googleapis.com/olympsis-1/announcements/Welcome%20Image%20-%20Basketball.jpg")]
}
