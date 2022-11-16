//
//  FieldsResponse.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import Foundation

/// The Fields Response is a struct conforms to the response of the api to get a list of fields, and decodes it.
struct FieldsResponse: Decodable {
    let totalFields: Int
    let fields: [Field]
    
    enum CodingKeys: String, CodingKey {
        case totalFields = "totalFields"
        case fields = "fields"
    }
}
