//
//  LocationTrackingInteractor.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation


/**
 This class updates its listeners when the tracking state changes.
 This class essentially acts as a simple dispatcher. It does not actually store the tracking state. Instead it is passed a new state which is sends to its listeners.
 The LocationUpdatedInteractor will actually store the tracking state.
*/

@objc enum TrackingState: Int {
    case TrackingOn
    case TrackingOff
    case TrackingUndefined // usually we would just use an optional trackingstate but exposing to obj-c prevents this
}

typealias TrackingStateListener = (TrackingState) -> ()

@objc class LocationTrackingInteractor: NSObject {
    
    private var m_trackingStateListener = [TrackingStateListener]()
    
    /** Note: a problem with using callbacks in the array is that there is no easy way to remove them
     due to no defined equality operations for callbacks. Instead if we want to add listeners we should clear ALL of the listeners first of all. Perhaps we should use Protocols instead of callbacks...🤔
    */
    func clearTrackingStateListeners() {
        m_trackingStateListener.removeAll()
    }
    
    func add(TrackingStateListener: @escaping TrackingStateListener) {
        m_trackingStateListener.append(TrackingStateListener)
    }        
    
    func updateTracking(WithNewState: TrackingState) {
        m_trackingStateListener.forEach{ $0(WithNewState) }
    }
}
