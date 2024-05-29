//
//  VenueTips.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/14/24.
//

import TipKit
import Foundation

struct JoinGroupTip: Tip {
    var title: Text {
        Text("Creating a new Event")
    }


    var message: Text? {
        Text("Creating events require that you are part of a group. Go to the groups page to join or create one.")
    }
    
    var options: [Option] {
        MaxDisplayCount(3)
    }
}
