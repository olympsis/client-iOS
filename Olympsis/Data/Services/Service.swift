//
//  Service.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import Foundation

protocol Service {
    var log : Logger { get }
    var http : HttpService { get set }
}

