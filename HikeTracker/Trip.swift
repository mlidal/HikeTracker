//
//  Trip.swift
//  HikeTracker
//
//  Created by Mathias Lidal on 15/08/16.
//  Copyright © 2016 Lidal. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class Trip {
    
    var id : String!
    var name : String!
    var desc : String!
    var length : Int!
    var time : Int!
    
    var waypoints = [CLLocationCoordinate2D]()
    var coordinates = [CLLocationCoordinate2D]()
    
    init(representation : JSON) {
        parseJSON(representation)
    }
    
    private func parseJSON(representation : JSON) {
        id = representation["_id"].stringValue
        name = representation["navn"].stringValue
        desc = representation["beskrivelse"].stringValue
        length = representation["distanse"].intValue
        let timeJSON = representation["tidsbruk"]["normal"]
        time = timeJSON["timer"].intValue * 3600 + timeJSON["minutter"].intValue * 60
        
        let waypoints = representation["geojson"]["properties"]["waypoints"].arrayValue
        
        for waypoint in waypoints {
            let coords = waypoint["coordinates"].arrayValue
            let longitude = coords[0].doubleValue
            let latitude = coords[1].doubleValue
            self.waypoints.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        
        let coordinates = representation["geojson"]["coordinates"].arrayValue
        for coordinate in coordinates {
            let longitude = coordinate[0].doubleValue
            let latitude = coordinate[1].doubleValue
            self.coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
    }
}