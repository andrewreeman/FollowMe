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
    Generated from the google developer console. Only com.stepwise.followme can use this apikey.
*/
fileprivate let API_KEY = "AIzaSyCX1gLWDC5ZsiXqUr6oEhGfmHlLm5tQWNY"

/**
 Wrapper for whatever Map api we use. At the moment we are using the googlemaps api
*/
@objc class MapApi: NSObject {
    override init() {
        GMSServices.provideAPIKey(API_KEY)
    }
    
    // Create a map view
    @objc func createMap() -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 53.3646193, longitude: -1.5047846, zoom: 15)
        return GMSMapView.map(withFrame: .zero, camera: camera)
    }
}
