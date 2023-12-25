//
//  NotificationModels.swift
//  Olympsis
//
//  Created by Joel on 11/15/23.
//

import Foundation

struct Notification: Codable {
    var title: String
    var body: String
}

struct NotificationModel: Codable {
    var id: String
    var type: String
    var club: Club?
    var event: Event?
    var organization: Organization?
    var invite: Invitation?
    var user: UserData?
    var body: String
}
