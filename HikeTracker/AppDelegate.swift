//
//  AppDelegate.swift
//  HikeTracker
//
//  Created by Mathias Lidal on 27/06/16.
//  Copyright © 2016 Lidal. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var realm : Realm!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        print(Realm.Configuration.defaultConfiguration.fileURL)

        let realmPath = NSBundle.mainBundle().pathForResource("default", ofType: ".realm")
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let newPath = directory + "/default.realm"
        if NSFileManager.defaultManager().fileExistsAtPath(newPath) {
            try! NSFileManager.defaultManager().removeItemAtPath(newPath)
        }
        try! NSFileManager.defaultManager().copyItemAtPath(realmPath!, toPath: newPath)
        
        let configuration = Realm.Configuration(fileURL: NSURL(fileURLWithPath: newPath))
        realm = try! Realm(configuration: configuration)
        
        var counties = realm.objects(County)
        print(counties.count)
        if counties.isEmpty {
            populateMunicipalities()
        }
        counties = realm.objects(County)
        print(counties.count)
        print(realm.objects(Municipality).count)
        if realm.objects(LocationType).isEmpty {
            populateTypes()
        }
        
        if realm.objects(Location).isEmpty {
            populatePlacenames()
        }
        
        return true
    }

    private func populatePlacenames() {
        let path = NSBundle.mainBundle().URLForResource("stedsnavn_pretty", withExtension: ".geojson")
        if path != nil {
            try! realm.write {
                let jsonData = NSData(contentsOfURL: path!)
                let json = JSON(data: jsonData!)
                let features = json["features"].arrayValue
                for feature in features {
                    let location = Location()
                    let properties = feature["properties"]
                    location.id = properties["enh_ssr_id"].intValue
                    location.municipality = realm.objectForPrimaryKey(Municipality.self, key: properties["enh_komm"].intValue)
                    location.type = realm.objectForPrimaryKey(LocationType.self, key: properties["enh_navntype"].intValue)
                    location.name = properties["enh_snavn"].stringValue
                    
                    let geometry = feature["geometry"]
                    let coordinates = geometry["coordinates"].arrayValue
                    location.longitude = coordinates[0].doubleValue
                    location.latitude = coordinates[1].doubleValue
                    if realm.objectForPrimaryKey(Location.self, key: location.id) == nil {
                        self.realm.add(location)
                    }
                }
            }
        }
    }
    
    private func populateTypes() {
        let path = NSBundle.mainBundle().URLForResource("placename_types", withExtension: ".csv")
        if path != nil {
            try! realm.write {
                let content = try! String(contentsOfURL: path!)
                content.enumerateLines({ line, _ in
                    let fields = line.componentsSeparatedByString(";")
                    let type = LocationType()
                    type.id = Int(fields[2])!
                    type.category = fields[1]
                    type.type = fields[0]
                    self.realm.add(type)
                })
            }
        }
    }
    
    private func populateMunicipalities() {
        let path = NSBundle.mainBundle().URLForResource("kommuner", withExtension: ".csv")
        if path != nil {
            try! realm.write {
                let content = try! String(contentsOfURL: path!)
                content.enumerateLines({ line, _ in
                    let fields = line.componentsSeparatedByString(";")
                    var county = self.realm.objectForPrimaryKey(County.self, key: Int(fields[0])!)
                    if county == nil {
                        county = County()
                        county!.id = Int(fields[0])!
                        county!.name = fields[1]
                        self.realm.add(county!)
                    }
                    let municipality = Municipality()
                    municipality.id = Int(fields[2])!
                    municipality.name = fields[3]
                    municipality.county = county
                    self.realm.add(municipality)
                })
                
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

