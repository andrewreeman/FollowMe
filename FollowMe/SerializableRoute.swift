//
//  SerializableRoute.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation
import EVReflection

/**
 Very simple classes for serialization using the EVReflection library
 */
@objc class SerializableRouteEntry: EVObject {
    var time = Date()
    var latitude = 0.0
    var longitude = 0.0
    
    init(FromRouteEntry: RouteEntry) {
        self.time = FromRouteEntry.time
        self.latitude = FromRouteEntry.location.latitude
        self.longitude = FromRouteEntry.location.longitude
    }
    
    required init() {}
}

@objc class SerializableRouteMetaData: EVObject {
    var id = ""
    var startTime = Date()
    var endTime = Date.init(timeIntervalSinceReferenceDate: 0)
    var distanceInMeters = 0
    var name = ""
    
    var isComplete: Bool {
        return startTime < endTime
    }
    
    init(FromRouteMetaData: RouteMetaData) {
        self.id = FromRouteMetaData.id
        self.startTime = FromRouteMetaData.startTime
        self.endTime = FromRouteMetaData.endTime
        self.distanceInMeters = FromRouteMetaData.distanceInMeters
        self.name = FromRouteMetaData.displayName
    }
    
    required init(){}
}

@objc class SerializableRoute: EVObject {
    var routeMetaData = SerializableRouteMetaData()
    var path = [SerializableRouteEntry]()
    
    init(FromRoute: Route) {
        self.routeMetaData = FromRoute.routeMetaData.serializable
        self.path = FromRoute.path.map{$0.serializable}
    }
    
    required init(){}
}
