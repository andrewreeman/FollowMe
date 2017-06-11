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
    private static var GMS_HAS_BEEN_INIT = false
    
    private let m_path = GMSMutablePath()
    private let m_gmsPolyline = GMSPolyline.init()
    private var m_markerImage: UIImage {
        let image = #imageLiteral(resourceName: "Marker")
        
        if let cgImage = image.cgImage {
            return UIImage.init(
                cgImage: cgImage,
                scale: 3.0,
                orientation: image.imageOrientation
            )
        }
        else {
            return image
        }
    }
    override init() {
        
        if !MapApi.GMS_HAS_BEEN_INIT {
            GMSServices.provideAPIKey(API_KEY)
            MapApi.GMS_HAS_BEEN_INIT = true
        }
        
        m_gmsPolyline.strokeWidth = 6
        
        // google map color
        m_gmsPolyline.strokeColor = UIColor.init(
            colorLiteralRed: 0.122, green: 0.706, blue: 0.980, alpha: 1.00
        )
    }
    
    // Create a map view
    @objc func createMap(WithFrame: CGRect) -> UIView {
        return createMap(
            WithFrame: WithFrame,
            AtCoordinates: CLLocationCoordinate2D.init(latitude: 53.3646193, longitude: -1.5047846)
        )
    }
    
    func createMap(WithFrame: CGRect, AtCoordinates: CLLocationCoordinate2D) -> UIView {
        let camera = GMSCameraPosition.camera(withLatitude: AtCoordinates.latitude, longitude: AtCoordinates.longitude, zoom: MapApi.ZOOM_LEVEL)
        let map =  GMSMapView.map(withFrame: WithFrame, camera: camera)
        map.isMyLocationEnabled = true
        
        if let myCoordinates = map.myLocation?.coordinate {
            let updateCamera = GMSCameraUpdate.setTarget(myCoordinates, zoom: MapApi.ZOOM_LEVEL)
            map.moveCamera(updateCamera)
        }
        m_gmsPolyline.map = map
        return map
    }
    
    
    func createMap(WithFrame: CGRect, AndRoute route: Route) -> UIView {
        let map: GMSMapView
        
        if let firstLocation = route.path.first {
            map = createMap(WithFrame: WithFrame, AtCoordinates: firstLocation.location) as! GMSMapView
            
            let startMarker = GMSMarker.init(position: firstLocation.location)
            startMarker.title = route.routeMetaData.displayName
            startMarker.snippet = route.startDescription
            // Kind of giving credit here... <a href="https://icons8.com/icon/7880/Marker-Filled">Marker filled icon credits</a>
            startMarker.icon = m_markerImage
            startMarker.map = map
            
            if let lastLocation = route.path.last {
                let lastMarker = GMSMarker.init(position: lastLocation.location)
                lastMarker.title = route.routeMetaData.displayName
                lastMarker.snippet = route.endDescription
                lastMarker.icon = m_markerImage
                lastMarker.map = map                
            }
            
        }
        else {
            map = createMap(WithFrame: WithFrame) as! GMSMapView
        }
        
        
        m_path.removeAllCoordinates()
        route.path.forEach {
            m_path.add($0.location)
        }
        
        m_gmsPolyline.path = m_path
        m_gmsPolyline.map = map
        
        
        
        return map
    }
    
    
    /**
     Update the map the latest coordinates
     We are passing a UIView instead of a GMSMapView because we are really trying to hide the google api just in this class where possible
    */
    func update(
        Map: UIView,
        ToLocation location: CLLocation,
        WithTrackingState: TrackingState
    )
    {
        guard let map = Map as? GMSMapView
        else {
            DebugLog.instance.error(Message: "Map is NOT a gms map view!")
            return
        }
        
        let updateCamera = GMSCameraUpdate.setTarget(location.coordinate, zoom: MapApi.ZOOM_LEVEL)
        map.moveCamera(updateCamera)
        
        switch WithTrackingState {
        case .TrackingOn:
            print("Tracking on...")
            m_path.add(location.coordinate)
            
            if m_gmsPolyline.map == nil {
                m_gmsPolyline.map = map
            }
        case .TrackingOff:
            print("Tracking off...")
            if m_gmsPolyline.map != nil {
                m_path.removeAllCoordinates()
                m_gmsPolyline.map = nil
            }
        default: break
        }
        
        m_gmsPolyline.path = m_path
    }
}
