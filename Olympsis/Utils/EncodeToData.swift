//
//  ConvertObjectToData.swift
//  Olympsis
//
//  Created by Noko Anubis on 4/8/23.
//

import Foundation

func EncodeToData<T: Encodable>(_ value: T) -> Data? {
    let encoder = JSONEncoder()
    
    return try? encoder.encode(value)
}
