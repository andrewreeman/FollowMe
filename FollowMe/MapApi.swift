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
    
    private let m_path = GMSMutablePath()
    private let m_gmsPolyline = GMSPolyline.init()
    
    override init() {
        GMSServices.provideAPIKey(API_KEY)
        
        m_gmsPolyline.strokeWidth = 6
        
        // google map color
        m_gmsPolyline.strokeColor = UIColor.init(
            colorLiteralRed: 0.122, green: 0.706, blue: 0.980, alpha: 1.00
        )
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
        m_gmsPolyline.map = map
        return map
    }
    
    
    // Update the map the latest coordinates
    func update(
        Map: GMSMapView,
        ToLocation location: CLLocation,
        WithTrackingState: TrackingState
    )
    {
        let updateCamera = GMSCameraUpdate.setTarget(location.coordinate, zoom: MapApi.ZOOM_LEVEL)
        Map.moveCamera(updateCamera)
        
        switch WithTrackingState {
        case .TrackingOn:
            m_path.add(location.coordinate)
            
            if m_gmsPolyline.map == nil {
                m_gmsPolyline.map = Map
            }
        case .TrackingOff:
            if m_gmsPolyline.map != nil {
                m_path.removeAllCoordinates()
                m_gmsPolyline.map = nil
            }
        default: break
        }
        
        m_gmsPolyline.path = m_path
    }
}
