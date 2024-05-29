//
//  FeedViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/23/24.
//

import Foundation

class FeedViewModel: ObservableObject {
    
    @Published var posts: [Post] = []
    @Published var status: LOADING_STATE = .pending
    
    func getLatestPosts() async {}
}
