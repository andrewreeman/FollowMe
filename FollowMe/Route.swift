//
//  Route.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

struct RouteMetaData {
    let id: String
    let startTime: Date
    let endTime: Date
    let distanceInMeters: Int
    
    var durationInSeconds: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var serializable: SerializableRouteMetaData {
        return SerializableRouteMetaData.init(FromRouteMetaData: self)
    }
    
    init(FromSerializable: SerializableRouteMetaData) {
        self.id = FromSerializable.id
        self.startTime = FromSerializable.startTime
        self.endTime = FromSerializable.endTime
        self.distanceInMeters = FromSerializable.distanceInMeters
    }
}

struct RouteEntry {
    let time: Date
    let location: CLLocationCoordinate2D
    
    var serializable: SerializableRouteEntry {
        return SerializableRouteEntry.init(FromRouteEntry: self)
    }
    
    init(FromSerializable: SerializableRouteEntry) {
        self.time = FromSerializable.time
        self.location = CLLocationCoordinate2D.init(
            latitude: FromSerializable.latitude, longitude: FromSerializable.longitude
        )
    }
}

struct Route {
    let routeMetaData: RouteMetaData
    let path: [RouteEntry]
    
    var serializable: SerializableRoute {
        return SerializableRoute.init(FromRoute: self)
    }
    
    init(FromSerializable: SerializableRoute) {
        self.routeMetaData = RouteMetaData.init(FromSerializable: FromSerializable.routeMetaData)
        self.path = FromSerializable.path.map{ RouteEntry.init(FromSerializable: $0) }
    }
}
