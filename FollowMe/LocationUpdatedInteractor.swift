//
//  LocationUpdatedInteractor.swift
//  FollowMe
//
//  Created by Andrew on 06/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

/** Whenever the location is updated we will call this listener with the current location and the current tracking state (if we are tracking or
 Swift note: ideally want the tracking state to be optional because we might not have defined it  but we can't due to exposing to obj-c
 */
typealias LocationUpdatedWithTrackingStateListener = (CLLocation, TrackingState) -> ()

/**
 This interactor will listen to location updates and pass the updates along with the current tracking state which this interactor stores.
*/
@objc class LocationUpdatedInteractor: NSObject {
    
    // MARK: public properties
    
    // gets and sets the listener for listening to location updates. This will be the PathViewController initially and then later the (not yet created: 06-08-2017) RouteInteractor
    private var m_locationUpdatedListener: LocationUpdatedWithTrackingStateListener?
    var locationUpdatedListener: LocationUpdatedWithTrackingStateListener? {
        get {
            return m_locationUpdatedListener
        }
        set {
            m_locationUpdatedListener = newValue
        }
    }
    
    /**
     This returns a callback that will be called every time the tracking state changes. 
     This will be used by the LocationTrackingInteractor which passes along tracking state changes from the ui.
    */
    private var m_trackingState: TrackingState = TrackingState.TrackingUndefined
    var trackingStateListener: TrackingStateListener {
        return {
            [weak self] in
            self?.m_trackingState = $0
        }
    }
    
    typealias StoppedMovingListener = () -> ()
    private var m_stoppedMovingListener: StoppedMovingListener?
    var stoppedMovingListener: StoppedMovingListener? {
        get {
            return m_stoppedMovingListener
        }
        set {
            m_stoppedMovingListener = newValue
        }
    }
        
    
    
    /**
     This callback is used by the LocationDelegate for triggering on every location update.
     This class will check that the new location is above a certain threshold before updates from this class.
    */
    private var m_currentLocation: CLLocation?
    var locationUpdated: LocationUpdatedListener {
        return {
            [weak self]
            (newLocationReceived) in                        
            
            guard let newLocation = newLocationReceived else { return }
            self?.update(ToNewLocation: newLocation)
        }
    }
    
    // Returns the current location usage according to the tracking state. This is used by the location delegate
    var locationUsage: LocationUsage {
        switch m_trackingState {
        case .TrackingOn: return ALWAYS
        case .TrackingOff: return IN_APP
        case .TrackingUndefined: return IN_APP
        }
    }
    
    // MARK: private methods
    /**
     Trigger the location updated listener only if the new location passes the distance threshold from the previous location.
    */
   // private var m_isCheckingStillMoving = false
    private func update(ToNewLocation newLocation: CLLocation) {
        guard let currentLocation = m_currentLocation
        else
        {
            m_currentLocation = newLocation
            return
        }
        
        if !newLocation.isNear(currentLocation) {
            m_currentLocation = newLocation
            locationUpdatedListener?(newLocation, m_trackingState)
        }
        
    /*    // if location is the same after 10 seconds turn off tracking
        if m_trackingState == .TrackingOff || m_isCheckingStillMoving { return }
        m_isCheckingStillMoving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            [weak self] in
            self?.m_isCheckingStillMoving = false
            
            guard let currentLocation = self?.m_currentLocation else { return }
            let oldLocation = newLocation
            
            // if old location is...near...current location
            oldLocation.distance(from: currentLocation)
            if oldLocation.isNear(currentLocation) {
                self?.m_stoppedMovingListener?()
            }
        }*/
    }
}

fileprivate let DISTANCE_THRESHOLD = 2.0 // meters
extension CLLocation {
    func isNear(_ location: CLLocation) -> Bool {
        return self.distance(from: location) <= DISTANCE_THRESHOLD
    }
}
