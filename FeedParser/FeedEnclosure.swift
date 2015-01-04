//
//  FeedEnclosure.swift
//
//  Created by Nacho on 12/10/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class FeedEnclosure: NSObject {
    var url: String
    var type: String
    var length: Int
    
    init(url: String, type: String, length: Int) {
        self.url = url
        self.type = type
        self.length = length
    }
}
