//
//  Error.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/6/25.
//

import Foundation

enum EventError: Error {
    case unknown
    case failedToAddParticipant
    case failedToRemoveParticipant
    case failedToAddTeam
    case failedToRemoveTeam
    case failedToAddComment
    case failedToRemoveComment
    case serverError
}

enum NewEventError: Error {
    case unknown(message: String)
    case unsafeMedia
    case invalidData
    case serverError(message: String)
}
