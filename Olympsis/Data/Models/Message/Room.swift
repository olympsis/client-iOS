//
//  GroupListView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/4/23.
//

import Foundation

struct Room: Decodable, Identifiable {
    let id: String
    let name: String
    let type: String
    let members: [ChatMember]
    let history: [Message]
}
