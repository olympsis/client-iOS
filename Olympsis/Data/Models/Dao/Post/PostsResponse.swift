//
//  PostsResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/25/22.
//

import Foundation

/// The Fields Response is a struct conforms to the response of the api to get a list of fields, and decodes it.
struct PostsResponse: Decodable {
    let totalPosts: Int
    let posts: [Post]
}

