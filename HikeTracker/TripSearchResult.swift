//
//  TripSearch.swift
//  HikeTracker
//
//  Created by Mathias Lidal on 15/08/16.
//  Copyright © 2016 Lidal. All rights reserved.
//

import Foundation

class TripSearchResult {
    
    var id : String
    var name : String
    var tags = [String]()
    
    init(id : String, name : String, tags : String) {
        self.id = id
        self.name = name
        self.tags = tags.componentsSeparatedByString(",")
    }
}