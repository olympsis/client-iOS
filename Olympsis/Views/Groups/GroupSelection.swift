//
//  GroupSelection.swift
//  Olympsis
//
//  Created by Joel on 11/25/23.
//

import SwiftUI
import Foundation

class GroupSelection: ObservableObject, Identifiable, Equatable {
    let id = UUID()
    let type: GROUP_TYPE
    let club: Club?
    let organization: Organization?
    @Published var posts: [Post]?
    
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
