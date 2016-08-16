//
//  TripDatabaseService.swift
//  HikeTracker
//
//  Created by Mathias Lidal on 15/08/16.
//  Copyright © 2016 Lidal. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class TripDatabaseService {
    
    var baseUrl : String = "https://dev.nasjonalturbase.no"
    
    /*init(baseUrl : String) {
        self.baseUrl = baseUrl
    }*/
    
    private func parseResult(response : Response<AnyObject, NSError>, completion : [TripSearchResult] -> Void) {
        var res = [TripSearchResult]()
        let json = JSON(response.result.value!)
        for trip in json["documents"].arrayValue {
            
            let trip = TripSearchResult(id: trip["_id"].stringValue, name: trip["navn"].stringValue, tags: "")
            res.append(trip)
        }
        completion(res)
    }
    
    func searchTrips(text : String, completion : [TripSearchResult] -> Void) {
        Alamofire.request(.GET, baseUrl + "/turer", parameters: ["navn": "~" + text]).validate().responseJSON() {
            response in
            self.parseResult(response, completion: completion)
        }
    }
    
    func nearbyTrips(location : CLLocation, distance : Int = 500, completion : [TripSearchResult] -> Void) {
        let nearby = String(format: "%f,%f", location.coordinate.longitude, location.coordinate.latitude, distance)
        Alamofire.request(.GET, baseUrl + "/turer?near=\(nearby)").validate().responseJSON() {
            response in
            self.parseResult(response, completion: completion)
        }
    }
    
    func tripsInRect(upperLeft : CLLocation, lowerRight : CLLocation, completion : [TripSearchResult] -> Void) {
        let bbox = String(format: "%f,%f,%f,%f", upperLeft.coordinate.longitude, upperLeft.coordinate.latitude, lowerRight.coordinate.longitude, lowerRight.coordinate.latitude)
        Alamofire.request(.GET, baseUrl + "/turer?bbox=\(bbox)").validate().responseJSON() {
            response in
            self.parseResult(response, completion: completion)
        }
    }
    
}