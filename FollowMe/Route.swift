//
//  Route.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

fileprivate let ROUTES_DATE_FORMATTER: () -> DateFormatter = {
    let dateFormatter = DateFormatter.init()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    return dateFormatter
}

func ==(lhs: RouteMetaData, rhs: RouteMetaData) -> Bool {
    let distanceEqual = lhs.distanceInMeters == rhs.distanceInMeters
    
    // rounding error will be because of deserializing dates
    let lhsDuration = lhs.durationInSeconds.rounded(.down)
    let rhsDuration = rhs.durationInSeconds.rounded(.down)
    let durationEqual = lhsDuration == rhsDuration
    
    let idEqual = lhs.id == rhs.id
    
    let lhsStartTime = ROUTES_DATE_FORMATTER().string(from: lhs.startTime)
    let rhsStartTime = ROUTES_DATE_FORMATTER().string(from: rhs.startTime)
    let startTimesEqual = lhsStartTime == rhsStartTime
    
    let lhsEndTime = ROUTES_DATE_FORMATTER().string(from: lhs.endTime)
    let rhsEndTime = ROUTES_DATE_FORMATTER().string(from: rhs.endTime)
    let endTimesEqual = lhsEndTime == rhsEndTime
    return distanceEqual && durationEqual && idEqual && startTimesEqual && endTimesEqual
}
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
    
    init() {
        self.id = UUID.init().uuidString
        self.startTime = Date()
        self.endTime = self.startTime
        self.distanceInMeters = 0
    }
    
    init(WithId: String, StartTime: Date, EndTime: Date, Distance: Int) {
        self.id = WithId
        self.startTime = StartTime
        self.endTime = EndTime
        self.distanceInMeters = Distance
    }
    
    func with(NewDistance: Int) -> RouteMetaData {
        return RouteMetaData.init(WithId: self.id, StartTime: self.startTime, EndTime: self.endTime, Distance: NewDistance)
    }
    
    func completeRoute() -> RouteMetaData {
        return RouteMetaData.init(WithId: self.id, StartTime: self.startTime, EndTime: Date(), Distance: self.distanceInMeters)
    }
    
}

func ==(lhs: RouteEntry, rhs: RouteEntry) -> Bool {
    let sameLatitude = lhs.location.latitude == rhs.location.latitude
    let sameLongitude = lhs.location.longitude == rhs.location.longitude
    
    let lhsTime = ROUTES_DATE_FORMATTER().string(from: lhs.time)
    let rhsTime = ROUTES_DATE_FORMATTER().string(from: rhs.time)
    let sameTime = lhsTime == rhsTime
    
    return sameLatitude && sameLongitude && sameTime
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
    
    init(WithTime: Date, AndLocation: CLLocationCoordinate2D) {
        self.time = WithTime
        self.location = AndLocation
    }
}

func ==(lhs: Route, rhs: Route) -> Bool {
    let metaDataEqual = lhs.routeMetaData == rhs.routeMetaData
    let pathsEqual = zip(lhs.path, rhs.path).reduce(true, { $0 && $1.0 == $1.1})
    
    return metaDataEqual && pathsEqual
}

final class Route {
    private var m_routeMetaData: RouteMetaData
    var routeMetaData: RouteMetaData {
        return m_routeMetaData
    }
    
    private var m_path: [RouteEntry]
    var path: [RouteEntry] {
        return m_path
    }
    
    var serializable: SerializableRoute {
        return SerializableRoute.init(FromRoute: self)
    }
        
    init(FromSerializable: SerializableRoute) {
        self.m_routeMetaData = RouteMetaData.init(FromSerializable: FromSerializable.routeMetaData)
        self.m_path = FromSerializable.path.map{ RouteEntry.init(FromSerializable: $0) }
    }
    
    init(WithRouteMetaData: RouteMetaData, AndPath: [RouteEntry]) {
        self.m_routeMetaData = WithRouteMetaData
        self.m_path = AndPath
    }
    
    init() {
        self.m_routeMetaData = RouteMetaData()
        self.m_path = [RouteEntry]()
    }
    
    func completeRoute() {
        self.m_routeMetaData = m_routeMetaData.completeRoute()
    }
    
    func add(RouteEntry entry: RouteEntry) {
        self.m_path.append(entry)
        self.m_routeMetaData = m_routeMetaData.with(NewDistance: calculateDistance() )
    }
    
    
    // MARK: private methods
    
    /**
     The total sum of the distance between each entry
     */
    private func calculateDistance() -> Int  {
        let calculationResult = self.m_path.map{$0.location}.reduce((0.0, nil))
        { (distanceAndPrevious: (CLLocationDistance, CLLocationCoordinate2D?), currentEntry) in
           
            guard let previousRouteEntry = distanceAndPrevious.1
            else { return (0.0, currentEntry) }
            
            let newDistance = distanceAndPrevious.0 + previousRouteEntry.distance(From: currentEntry)
            return (newDistance, currentEntry)
        }
        return Int(calculationResult.0)
    }
    
}
