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

fileprivate enum MarkerLocation {
    case start(CLLocationCoordinate2D)
    case end(CLLocationCoordinate2D)
}

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
    
    /** Create map with default coordinates */
    func createMap(WithFrame: CGRect) -> UIView {
        return createMap(
            WithFrame: WithFrame,
            AtCoordinates: CLLocationCoordinate2D.init(latitude: 53.3646193, longitude: -1.5047846)
        )
    }
    
    /** create a map view at the specified coordinates */
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
    
    
    /** create a map view and display the given route if possible */
    func createMap(WithFrame: CGRect, AndRoute route: Route) -> UIView {
        let map: GMSMapView
        
        if let firstLocation = route.path.first, let lastLocation = route.path.last {
            map = createMap(WithFrame: WithFrame, AtCoordinates: firstLocation.location) as! GMSMapView
            
            // create start marker
            createMarkerFor(
                location: .start(firstLocation.location),
                ForRoute: route
            ).map = map
            
            // create end marker
            createMarkerFor(
                location: .end(lastLocation.location),
                ForRoute: route
            ).map = map
            
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
    
    // MARK: private methods    
    
    private func createMarkerFor(location: MarkerLocation, ForRoute route: Route) -> GMSMarker {
        let marker: GMSMarker
        
        switch location {
        case .start(let location):
            marker = GMSMarker.init(position: location)
            marker.snippet = route.startDescription
        case .end(let location):
            marker = GMSMarker.init(position: location)
            marker.snippet = route.endDescription
        }
        
        marker.title = route.routeMetaData.displayName
        marker.icon = m_markerImage
        return marker
    }
    
    
}
