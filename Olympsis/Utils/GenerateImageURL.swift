//
//  GenerateImageURL.swift
//  Olympsis
//
//  Created by Noko Anubis on 4/9/23.
//

import Foundation

func GenerateImageURL(_ link: String) -> String {
    return "https://api.olympsis.com/" + link
}

func GrabImageIdFromURL(_ url: String) -> String {
    let url = URL(fileURLWithPath: url)
    return url.lastPathComponent
}
