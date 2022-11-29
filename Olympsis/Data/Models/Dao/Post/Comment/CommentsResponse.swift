//
//  CommentsResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

/// The Fields Response is a struct conforms to the response of the api to get a list of fields, and decodes it.
struct CommentsResponse: Decodable {
    let totalComments: Int
    let comments: [Comment]
}
