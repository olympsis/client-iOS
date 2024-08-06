//
//  VenueSearchViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/3/24.
//

import SwiftUI
import Combine
import Foundation

class VenueSearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var debouncedSearchText: String = ""

   private var cancellables = Set<AnyCancellable>()

   init() {
       $searchText
           .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
           .removeDuplicates()
           .assign(to: \.debouncedSearchText, on: self)
           .store(in: &cancellables)
   }
}
