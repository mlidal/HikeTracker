//
//  ViewController.swift
//  HikeTracker
//
//  Created by Mathias Lidal on 27/06/16.
//  Copyright © 2016 Lidal. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    var locationManager : CLLocationManager!
    var realm : Realm!
    var nearbyLocations = [Location]()
    var nearbyTripItems = [TripSearchResult]()
    
    var currentLocation : CLLocation!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var tripDatabaseService = TripDatabaseService()
    
    var visibleView : UIView!
    var hiddenView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        visibleView = tableView
        hiddenView = mapView
        
        realm = try! Realm()
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() != .Denied && CLLocationManager.authorizationStatus() != .Restricted {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                if CLLocationManager.authorizationStatus() == .NotDetermined {
                    locationManager.requestAlwaysAuthorization()
                } else {
                    locationManager.startUpdatingLocation()
                    mapView.showsUserLocation = true
                    
                }
            }
        } else {
            print("Location services disabled")
        }
        
        let overlay = MKTileOverlay(URLTemplate: "https://opencache.statkart.no/gatekeeper/gk/gk.open_wmts?SERVICE=WMTS&version=1.0.0&request=GetTile&format=image/png&TileMatrixSet=EPSG:3857&TileMatrix=EPSG:3857:{z}&TileRow={y}&TileCol={x}&Layer=norges_grunnkart&Style=default")
        mapView.addOverlay(overlay)
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay)
        return renderer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
        tripDatabaseService.nearbyTrips(currentLocation, completion: {
            result in
            self.nearbyTripItems = result
            self.tableView.reloadData()
        })
        findNearbyLocations(currentLocation)
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func flipView(sender: AnyObject) {
        UIView.transitionFromView(visibleView, toView: hiddenView, duration: 1.0, options: [.ShowHideTransitionViews, .TransitionFlipFromRight
        ], completion: nil)
    }
    
    private func findNearbyLocations(location : CLLocation) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        let minLat = region.center.latitude - (region.span.latitudeDelta / 2.0)
        let maxLat = region.center.latitude + (region.span.latitudeDelta / 2.0)
        let minLon = region.center.longitude - (region.span.longitudeDelta / 2.0)
        let maxLon = region.center.longitude + (region.span.longitudeDelta / 2.0)
        let locations = realm.objects(Location).filter("latitude > %@ and latitude < %@ and longitude > %@ and longitude < %@", minLat, maxLat, minLon, maxLon)
        print(locations.count)
        nearbyLocations = Array(locations)
        
        mapView.addAnnotations(nearbyLocations)
        mapView.showAnnotations(nearbyLocations, animated: true)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyTripItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell")
        let tripItem = nearbyTripItems[indexPath.row]
        cell?.textLabel?.text = tripItem.name
        //cell?.detailTextLabel!.text = "\(currentLocation.distanceFromLocation(location.position))"
        return cell!
    }
    
}

