//
//  Location.swift
//  HikeTracker
//
//  Created by Mathias Lidal on 11/08/16.
//  Copyright © 2016 Lidal. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import MapKit

class LocationType : Object {
    
    dynamic var id = 0
    dynamic var type = ""
    dynamic var category = ""

    override static func primaryKey() -> String? {
        return "id"
    }

}

class County : Object {
    dynamic var id = 0
    dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Municipality : Object {
    dynamic var id = 0
    dynamic var name = ""
    dynamic var county : County!
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Location: Object, MKAnnotation {
    dynamic var id = 0
    dynamic var name = ""
    dynamic var type : LocationType!
    dynamic var municipality : Municipality!
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0

    var position : CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var coordinate : CLLocationCoordinate2D {
        get {
            return position.coordinate
        }
    }
    
    var title: String? {
        get {
            return name
        }
    }

    override static func primaryKey() -> String? {
        return "id"
    }
    
}
