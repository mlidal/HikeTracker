//
//  Trip.swift
//  HikeTracker
//
//  Created by Mathias Lidal on 15/08/16.
//  Copyright © 2016 Lidal. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class TripPoint : Object {
    dynamic var longitude = 0.0
    dynamic var latitude = 0.0
    dynamic var speed = 0.0
    dynamic var height = 0.0
    dynamic var course = 0.0
    dynamic var timestamp : NSDate!
}

class LoggedTrip: Object {
    dynamic var startTime : NSDate!
    dynamic var endTime : NSDate!
    
    let tripPoints = List<TripPoint>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
