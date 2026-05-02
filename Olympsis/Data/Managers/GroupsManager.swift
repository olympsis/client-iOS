//
//  GroupManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/29/25.
//

import SwiftUI
import Foundation

@Observable
class GroupsManager {
    
    var selected: GroupSelection? {
        didSet {
            guard let group = selected,
                  let id = group.club?.id ?? group.organization?.id
            else { return }
            
            selectedGroupID = id
        }
    }
    
    var groups = [GroupSelection]()
    var posts: [String: [Post]] = [:]
    
    @ObservationIgnored
    @AppStorage("selected_group_id") var selectedGroupID: String?
    
    init() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name.groupAddedServerSide,
            object: nil,
            queue: .main
        ) { update in
            self.handleGroupAddedServerSide(update)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .groupAddedServerSide,
            object: nil
        )
    }
    
    /// Adds a group to the group manager
    /// - Parameter group: the `GroupSelection` we are adding
    func add(_ group: GroupSelection) {
        groups.append(group)
    }
    
    /// Removes a group from the group manager
    /// - Parameter group: the `GroupSelection` we are removing
    /// - Removes all of the posts associated with the group upon removal
    /// - Selects the first group after group removal
    func remove(_ group: GroupSelection) {
        guard let id = group.club?.id ?? group.organization?.id
            else { return }
        
        posts.removeValue(forKey: id)
        groups.removeAll { $0.id == group.id }
        
        guard let first = groups.first else {
            selected = nil
            return
        }
        select(first)
    }
    
    /// Selects a group
    /// - Parameter group: the `GroupSelection` we are selecting
    func select(_ group: GroupSelection) {
        self.selected = group
    }
    
    /// Restores the last selected group
    /// - Checks to see if we have a selected group id in app storage
    /// - If we don't have any stored in app storage we select the first of the groups
    func restore() {
        guard let id = selectedGroupID,
              let group = groups.first(where: { $0.club?.id == id || $0.organization?.id == id }) else {
            self.selected = groups.first
            return
        }
        self.selected = group
    }
    
    /// Handles the group added server-side notification
    /// - Parameter update: the `NSNotification` object to process
    /// - Grabs the group type and fetches either the club or the organization associated
    /// - Adds the new group to the manager and sets the selected group to the newly added one
    func handleGroupAddedServerSide(_ update: Notification) {
        guard let _type = update.userInfo?["type"] as? String,
              let type = GROUP_TYPE(rawValue: _type),
            let groupID = update.userInfo?["group_id"] as? String else {
                return
            }
        Task {
            switch type {
            case .Club:
                guard let club = await ClubObserver.shared.getClub(id: groupID) else {
                    return
                }
                let group = GroupSelection(type: .Club, club: club)
                self.add(group)
                self.selected = group
            case .Organization:
                guard let org = await OrgObserver.shared.getOrganization(id: groupID) else {
                    return
                }
                let group = GroupSelection(type: .Organization, organization: org)
                self.add(group)
                self.selected = group
            }
        }
    }
}
