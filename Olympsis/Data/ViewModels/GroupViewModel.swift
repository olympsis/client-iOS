//
//  GroupViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/3/24.
//

import Combine
import Foundation

class GroupViewModel: ObservableObject {
    
    @Published var selectedGroup: GroupSelection?
    @Published var state: LOADING_STATE = .pending
    
    private var cancellables = Set<AnyCancellable>()
    
    init(session: SessionStore) {
//        session.clubsState
//            .assign(to: \.state, on: self)
//            .store(in: &cancellables)
    }
}
