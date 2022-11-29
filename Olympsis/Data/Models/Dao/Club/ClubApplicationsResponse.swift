//
//  ClubApplicationsResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

struct ClubApplicationsResponse: Decodable {
    let totalApplications: Int
    let applications: [ClubApplication]
}
