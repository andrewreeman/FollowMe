//
//  LocationTrackingInteractor.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation


/**
 This class will contain the state for if tracking is turned on or off.
 If the state changes it will update its listeners
*/

@objc enum TrackingState: Int {
    case TrackingOn
    case TrackingOff
    case TrackingUndefined // usually we would just use an optional trackingstate but exposing to obj-c prevents this
}

typealias TrackingStateListener = (TrackingState) -> ()

@objc class LocationTrackingInteractor: NSObject {
    
    private var m_trackingStateListener = [TrackingStateListener]()
    
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
