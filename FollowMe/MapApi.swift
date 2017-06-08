//
//  MapApi.swift
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation
import GoogleMaps

/**
    Generated from the google developer console. Only com.stepwise.followme can use this apikey. Super insecure having it hardcoded here!
*/
fileprivate let API_KEY = "AIzaSyCX1gLWDC5ZsiXqUr6oEhGfmHlLm5tQWNY"

/**
 Wrapper for whatever Map api we use. At the moment we are using the googlemaps api
*/
@objc class MapApi: NSObject {
    private static let ZOOM_LEVEL = Float(15)
    
    override init() {
        GMSServices.provideAPIKey(API_KEY)
    }
    
    // Create a map view
    @objc func createMap(WithFrame: CGRect) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 53.3646193, longitude: -1.5047846, zoom: MapApi.ZOOM_LEVEL)
        let map =  GMSMapView.map(withFrame: WithFrame, camera: camera)
        map.isMyLocationEnabled = true
        
        if let myCoordinates = map.myLocation?.coordinate {
            let updateCamera = GMSCameraUpdate.setTarget(myCoordinates, zoom: MapApi.ZOOM_LEVEL)
            map.moveCamera(updateCamera)
        }
        
        return map
    }
    
    // Update the map the latest coordinates
    func update(Map: GMSMapView, ToLocation location: CLLocation) {        
        let updateCamera = GMSCameraUpdate.setTarget(location.coordinate, zoom: MapApi.ZOOM_LEVEL)
        Map.moveCamera(updateCamera)
    }
}
