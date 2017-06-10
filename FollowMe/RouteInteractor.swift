//
//  RouteInteractor.swift
//  FollowMe
//
//  Created by Andrew on 08/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

/**
 This file will contain a RouteInteractor class.
 This will deal with listening to location updates and recording the route if tracking is on.
 It will then update the ui after receiving a location update. 

*/

class RouteInteractor {
    
    private let m_routesFileStore: RoutesFileStore?
    private var m_route: Route?
    
    private var m_uiUpdateListener: LocationUpdatedWithTrackingStateListener?
    var uiUpdateListener: LocationUpdatedWithTrackingStateListener? {
        get {
            return m_uiUpdateListener
        }
        set {
            m_uiUpdateListener = newValue
        }
    }
    
    
    var routeUpdated: RouteFileStoreUpdated? {
        get {
            return m_routesFileStore?.updatedListener
        }
        set {
            m_routesFileStore?.updatedListener = newValue
        }
    }
    
    /** 
     This is the callback that will be triggered on every location update
     When the tracking is on it will start a new route or append to an existing route
     When the tracking is off it will complete the current route if there is one
     After any route changes we will then update the ui
    */
    var locationUpdated: LocationUpdatedWithTrackingStateListener {
        return {
            [weak self]
            (location, trackingState) in
            
            switch (trackingState, self?.m_route) {
            case (.TrackingOff, .some(let route)):
                route.add(RouteEntry: RouteEntry.init(WithLocation: location.coordinate))
                route.completeRoute()
                self?.m_routesFileStore?.update(Route: route)
                self?.m_route = nil
            case (.TrackingOn, _):
                // this operator will only evaluate the function on the right if the left is nil
                self?.m_route ?= { Route.init() }
                if let route = self?.m_route {
                    route.add(RouteEntry: RouteEntry.init(WithLocation: location.coordinate))
                    self?.m_routesFileStore?.update(Route: route)
                }
                else {
                    DebugLog.instance.error(Message: "Route should be initialised!")
                }
                
            default: break
            }
            self?.uiUpdateListener?(location, trackingState)
        }
    }
    
    init() {
        m_routesFileStore = RoutesFileStore.init()
                    
        if m_routesFileStore == nil {
            DebugLog.instance.error(Message: "Could not create routes file store!")
        }
    }
}
