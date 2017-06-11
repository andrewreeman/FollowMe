//
//  Route.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

/**
 This contains all of the route models used for tracking the users route.
 The main model is 'Route' which contains a list of 'RouteEntry' and a single 'RouteMetaData'
*/
import Foundation

/**
 This is the internal date formatter used by the routes. 
 The format should not be relied upon by anything outside of this file.
*/
fileprivate let ROUTES_DATE_FORMATTER: () -> DateFormatter = {
    let dateFormatter = DateFormatter.init()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    return dateFormatter
}

// Comparisong between two RouteMetaData
func ==(lhs: RouteMetaData, rhs: RouteMetaData) -> Bool {
    let distanceEqual = lhs.distanceInMeters == rhs.distanceInMeters
           
    let idEqual = lhs.id == rhs.id
    
    let lhsStartTime = ROUTES_DATE_FORMATTER().string(from: lhs.startTime)
    let rhsStartTime = ROUTES_DATE_FORMATTER().string(from: rhs.startTime)
    let startTimesEqual = lhsStartTime == rhsStartTime
    
    let lhsEndTime = ROUTES_DATE_FORMATTER().string(from: lhs.endTime)
    let rhsEndTime = ROUTES_DATE_FORMATTER().string(from: rhs.endTime)
    let endTimesEqual = lhsEndTime == rhsEndTime
    return distanceEqual && idEqual && startTimesEqual && endTimesEqual
}

/**
 The RouteMetaData contains the identifier, start and end times of the route and also the distance in meters. The routemetadata will primarily be used in the route display list.
*/
struct RouteMetaData {
    
    // the unique id of this route. This is a uuid. This will make up the filename of the route.
    let id: String
    
    // when the user started tracking
    let startTime: Date
    var startTimeString: String {
        return ROUTES_DATE_FORMATTER().string(from: self.startTime)
    }
    
    // when the user stopped tracking
    let endTime: Date
    
    private var name: String
    var displayName: String {
        get {
            return name.isEmpty ? startTimeString : name
        }
    }
    
    // the total distance in meters of the route
    let distanceInMeters: Int
    
    // the total duration in seconds of the route
    var durationInSeconds: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var isComplete: Bool {
        return endTime > startTime
    }
    
    // a serializable version of the route meta data for storing to disk
    var serializable: SerializableRouteMetaData {
        return SerializableRouteMetaData.init(FromRouteMetaData: self)
    }
    
    init(FromSerializable: SerializableRouteMetaData) {
        self.id = FromSerializable.id
        self.startTime = FromSerializable.startTime
        self.name = FromSerializable.name
        self.endTime = FromSerializable.endTime
        self.distanceInMeters = FromSerializable.distanceInMeters
    }
    
    init() {
        self.id = UUID.init().uuidString
        self.startTime = Date()
        self.endTime = Date.init(timeIntervalSinceReferenceDate: 0)
        self.distanceInMeters = 0
        
        // need to set to empty string first because of silly Swift things. All properties must be init first before calling any methods/computedproperties
        self.name = ""
        self.name = startTimeString
    }
   
    init(WithId: String, StartTime: Date, EndTime: Date, Distance: Int) {
        self.id = WithId
        self.startTime = StartTime
        self.endTime = EndTime
        self.distanceInMeters = Distance
        
        self.name = ""
        self.name = startTimeString
    }
    
    init(WithId: String, StartTime: Date, EndTime: Date, Distance: Int, DisplayName: String) {
        self.id = WithId
        self.startTime = StartTime
        self.endTime = EndTime
        self.distanceInMeters = Distance
        self.name = DisplayName
    }
    
    func with(NewDistance: Int) -> RouteMetaData {
        return RouteMetaData.init(
            WithId: self.id, StartTime: self.startTime, EndTime: self.endTime, Distance: NewDistance, DisplayName: self.displayName
        )
    }
    
    func with(NewDisplayName: String) -> RouteMetaData {
        return RouteMetaData.init(
            WithId: self.id, StartTime: self.startTime, EndTime: self.endTime, Distance: self.distanceInMeters, DisplayName: NewDisplayName
        )
    }
    
    // Sets the end time of the route and returns the new RouteMetaData
    func completeRoute() -> RouteMetaData {
        return RouteMetaData.init(
            WithId: self.id, StartTime: self.startTime, EndTime: Date(), Distance: self.distanceInMeters
        )
    }
}

// comparisong between two RouteEntry objects
func ==(lhs: RouteEntry, rhs: RouteEntry) -> Bool {
    let sameLatitude = lhs.location.latitude == rhs.location.latitude
    let sameLongitude = lhs.location.longitude == rhs.location.longitude
    
    let lhsTime = ROUTES_DATE_FORMATTER().string(from: lhs.time)
    let rhsTime = ROUTES_DATE_FORMATTER().string(from: rhs.time)
    let sameTime = lhsTime == rhsTime
    
    return sameLatitude && sameLongitude && sameTime
}

/**
 The route entry is the heart of the tracking app! This stores a coordinate and a time. 
 A route will essentially comprise of a list of these along with some meta data
*/
struct RouteEntry {
    
    // the time when this was created
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
    
    // This is the consturctor that will primarily be used as we will rarely be creating RouteEntry with a different date from now except in testing
    init(WithLocation: CLLocationCoordinate2D) {
        self.init(WithTime: Date(), AndLocation: WithLocation)
    }
}

// comparison between two routes
func ==(lhs: Route, rhs: Route) -> Bool {
    let metaDataEqual = lhs.routeMetaData == rhs.routeMetaData
    
    /**
     this is a very swifty way of comparisong two lists.
     First we use zip to create a list of pairs from each list. 
     Then we use reduce to compare every pair with each other. We start the reduce with 'true' because otherwise the whole thing will result in being false (...found after testing! 🙄)
    */
    let pathsEqual = zip(lhs.path, rhs.path).reduce(true, { $0 && $1.0 == $1.1})
    
    return metaDataEqual && pathsEqual
}


/**
 This is marked as final. Same function as 'final' in Java. 
 The reason this needs to be final is because in Extensions/RandomGeneratable.swift file we apply the 
 RandomGeneratable protocol to Route. This protocol contains a reference to 'Self' which is the type of class. Swift seems to only be able resolve what 'Self' is on entities that can not have any inheritence, i.e structs and 'final' classes.
*/
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
    
    var startDescription: String {
        return makeMarkerTitle(ForRouteEntry: m_path.first)
    }
    
    var endDescription: String {
        return makeMarkerTitle(ForRouteEntry: m_path.last)
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
    
    // Used for when the user has stopped tracking
    func completeRoute() {
        self.m_routeMetaData = m_routeMetaData.completeRoute()
    }
    
    func set(Name: String) {
        self.m_routeMetaData = m_routeMetaData.with(NewDisplayName: Name)
    }
    
    // Adds an entry to the path and creates a new meta data with a new distance
    func add(RouteEntry entry: RouteEntry) {
        self.m_path.append(entry)
        self.m_routeMetaData = m_routeMetaData.with(NewDistance: calculateDistance() )
    }
    
    
    // MARK: private methods
    
    /**
     The total sum of the distance between each entry. At the time of writing (08/06/2017: election day) this has not been tested at all!
     */
    private func calculateDistance() -> Int  {
        /**
         first we use map to get just the locations
         then we use reduce to iterate over each location.
         In reduce we will be passing a tuple that contains the distance so far and the previous coordinate.
         We need this previous coordinate because we will be working out the distance between that and the current coordinate.
         
         */
        let calculationResult = self.m_path.map{$0.location}.reduce((0.0, nil))
        { (distanceAndPrevious: (CLLocationDistance, CLLocationCoordinate2D?), currentEntry) in
            // if there is no previous coordinate then the current distance is zero and set current entry for the next iteration
            guard let previousRouteEntry = distanceAndPrevious.1
            else { return (0.0, currentEntry) }
            
            // add to previous distance
            let newDistance = distanceAndPrevious.0 + previousRouteEntry.distance(From: currentEntry)
            return (newDistance, currentEntry)
        }        
        return Int(calculationResult.0)
    }
    
    private func makeMarkerTitle(ForRouteEntry: RouteEntry?) -> String {
        guard let routeEntry = ForRouteEntry
        else {
            return ROUTES_DATE_FORMATTER().string(from: routeMetaData.startTime)
        }
        
        let entryTime = ROUTES_DATE_FORMATTER().string(from:  routeEntry.time)
        let entryLocation = "Lat: \( routeEntry.location.latitude)\nLon: \( routeEntry.location.longitude)"
        return "\(entryTime)\n\(entryLocation)"
        
    }
    
}
