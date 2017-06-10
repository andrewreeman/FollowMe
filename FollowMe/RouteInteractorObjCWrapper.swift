//
//  RouteInteractorObjCWrapper.swift
//  FollowMe
//
//  Created by Andrew on 10/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

@objc class RouteInteractorObjCWrapper: NSObject {
    private let m_routeInteractor: RouteInteractor
    
    override init() {
        m_routeInteractor = RouteInteractor()
        
    }
    
    @objc var locationUpdated: LocationUpdatedWithTrackingStateListener {
        
        return m_routeInteractor.locationUpdated
    }
    
   /* // taking advantage of the fact that the serializable route is the same as the route
    // however...this means the WHOLE route is serialized every time...
    @objc func setRouteUpdatedListener(
        routeUpdatedListenerForObjC:
            @escaping (RouteFileStoreTransactionType, SerializableRoute?, String?) -> ()
    )
    {
        m_routeInteractor.routeUpdated = {
            (transaction, route, error) in
            
            routeUpdatedListenerForObjC(
                transaction,
                route?.serializable,
                error?.localizedDescription
            )
        
        }
    }*/
    
    @objc func setUiUpdateListener(
        _ listener: @escaping LocationUpdatedWithTrackingStateListener
    )
    {
        m_routeInteractor.uiUpdateListener = listener
    }
    
    
    
    
    
    
}
