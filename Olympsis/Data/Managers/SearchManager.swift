//
//  SearchManager.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/30/25.
//

import MapKit
import Foundation

@Observable
class SearchManager {
    
    var tags: [Tag] = []
    var sports: [Sport] = []
    
    var radius: Double = 0
    var selectedTags: [String] = []
    var selectedSports: [String] = []
    var mapRegion: MKCoordinateRegion?
    
    func selectSport(_ sport: Sport) {
        let name = sport.name.components(separatedBy: " ")[1]
        if selectedSports.contains(name) {
            selectedSports.removeAll { $0 == name }
        } else {
            selectedSports.append(name)
        }
    }
    
    func isSportSelected(_ sport: Sport) -> Bool {
        return selectedSports.contains(sport.name.components(separatedBy: " ")[1])
    }
    
    func getSportsString() -> String {
        return selectedSports.joined(separator: ",")
    }
    
    func selectTag(_ tag: Tag) {
        let name = tag.name
        if selectedTags.contains(name) {
            selectedTags.removeAll { $0 == name }
        } else {
            selectedTags.append(name)
        }
    }
    
    func isTagSelected(_ tag: Tag) -> Bool {
        return selectedTags.contains(tag.name)
    }
    
    func getTagsString() -> String {
        return selectedTags.joined(separator: ",")
    }
}
