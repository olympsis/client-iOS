//
//  CommentDao.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/28/22.
//

import Foundation

class CommentDao: Dao {
    let uuid: String
    let text: String
    
    init(_uuid: String, _text: String) {
        self.uuid = _uuid
        self.text = _text
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(text, forKey: .text)
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case text

    }
}
