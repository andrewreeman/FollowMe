//
//  LocationUpdatedInteractor.swift
//  FollowMe
//
//  Created by Andrew on 06/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

@objc class LocationUpdatedInteractor: NSObject {
    private static let DISTANCE_THRESHOLD = 2.0 // meters
    
    private var m_locationUpdatedListener: LocationUpdatedListener?
    var locationUpdatedListener: LocationUpdatedListener? {
        get {
            return m_locationUpdatedListener
        }
        set {
            m_locationUpdatedListener = newValue
        }
    }
    
    private var m_currentLocation: CLLocation?
    var locationUpdated: LocationUpdatedListener {
        return {
            [weak self]
            (newLocationReceived) in                        
            
            guard let newLocation = newLocationReceived else { return }
            self?.update(ToNewLocation: newLocation)
            
            return
        }
    }
    
    var locationUsage: LocationUsage {
        return IN_APP;
    }
    
    private func update(ToNewLocation newLocation: CLLocation) {
        guard let currentLocation = m_currentLocation
        else
        {
            m_currentLocation = newLocation
            return
        }
        
        let distanceFromCurrentLocation = newLocation.distance(from: currentLocation)
        let shouldUpdate = distanceFromCurrentLocation >=
            LocationUpdatedInteractor.DISTANCE_THRESHOLD
        if shouldUpdate {
            m_currentLocation = newLocation
            m_locationUpdatedListener?(newLocation)
        }
    }
    
}
