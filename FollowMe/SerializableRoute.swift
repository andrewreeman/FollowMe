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
class SerializableRouteEntry: EVObject {
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

class SerializableRouteMetaData: EVObject {
    var id = ""
    var startTime = Date()
    var endTime = Date()
    var distanceInMeters = 0
    
    init(FromRouteMetaData: RouteMetaData) {
        self.id = FromRouteMetaData.id
        self.startTime = FromRouteMetaData.startTime
        self.endTime = FromRouteMetaData.endTime
        self.distanceInMeters = FromRouteMetaData.distanceInMeters
    }
    
    required init(){}
}

class SerializableRoute: EVObject {
    var routeMetaData = SerializableRouteMetaData()
    var path = [SerializableRouteEntry]()
    
    init(FromRoute: Route) {
        self.routeMetaData = FromRoute.routeMetaData.serializable
        self.path = FromRoute.path.map{$0.serializable}
    }
    
    required init(){}
}
