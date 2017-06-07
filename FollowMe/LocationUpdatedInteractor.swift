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
    
    // ideally want the tracking state to be optional but we can't due to exposing to obj-c
    typealias LocationUpdatedWithTrackingStateListener = (CLLocation, TrackingState) -> ()
    
    private var m_locationUpdatedListener: LocationUpdatedWithTrackingStateListener?
    var locationUpdatedListener: LocationUpdatedWithTrackingStateListener? {
        get {
            return m_locationUpdatedListener
        }
        set {
            m_locationUpdatedListener = newValue
        }
    }
    
    private var m_trackingState: TrackingState = TrackingState.TrackingUndefined
    var trackingStateListener: TrackingStateListener {
        return {
            [weak self] in
            self?.m_trackingState = $0
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
        switch m_trackingState {
        case .TrackingOn: return ALWAYS
        case .TrackingOff: return IN_APP
        case .TrackingUndefined: return IN_APP
        }
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
            m_locationUpdatedListener?(newLocation, m_trackingState)
        }
    }
    
}
