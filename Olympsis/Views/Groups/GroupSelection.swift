//
//  GroupSelection.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import SwiftUI
import Foundation

@Observable
class GroupSelection: Identifiable, Equatable {
    let id = UUID()
    let type: GROUP_TYPE
    let club: Club?
    let organization: Organization?
    var posts: [Post]?
    
    var groupID: String? {
        switch type {
        case .Club:
            return club?.id
        case .Organization:
            return organization?.id
        }
    }
    
    init(type: GROUP_TYPE, club: Club?=nil, organization: Organization?=nil, posts: [Post]? = nil) {
        self.type = type
        self.club = club
        self.organization = organization
        self.posts = posts
    }
    
    static func == (lhs: GroupSelection, rhs: GroupSelection) -> Bool {
        return lhs.id == rhs.id
    }
}
