//
//  RandomGeneratable.swift
//  FollowMe
//
//  Created by Andrew on 08/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

/**
 This file contains classes that will mainly be used for random data generation for testing. 
 At the moment the random generation is not good enough for creating actualy usable sample data as it is too noisy. It is useful for testing though
*/

protocol RandomGeneratable {
    static func random() -> Self
    func random() -> Self
}


// This is a nice way of saying we want an array of N elements with random data
// Note that it uses the 'map' extension on Int defined in the Common.swift file
extension RandomGeneratable {
    static func random(ForCount: Int) -> [Self] {
        return Self.random().random(ForCount: ForCount)
    }
    
    func random(ForCount: Int) -> [Self] {
        return ForCount.map{(_) in self.random()}
    }
}

/* Interesting note about this is that you can do...
 let twiceAsRandom = Double.random().random()
*/
extension Double: RandomGeneratable {
    
    // Returns a random double
    static func random() -> Double {
        return Double(arc4random())
    }
    
    // Returns a random double that is less than 'self'
    func random() -> Double {
        /**
         The reason for the complexity of this is that we were getting overflows when double was higher than UInt32 max or min
        */
        let uintValue: UInt32
        
        switch self {
        case let x where x > Double(UInt32.max):
            uintValue = UInt32.max
        case let x where x < Double(UInt32.min):
            uintValue = UInt32.min
        default:
            uintValue = UInt32(self)
        }
        
        let random = arc4random_uniform(uintValue)
        return Double(random)
    }
}

// Returns random ints
extension Int: RandomGeneratable {
    static func random() -> Int {
        return Int.max.random()
    }
    
    func random() -> Int {
        return Int(Double(self).random())
    }
}

// Returns completely random locations...probably in the sea or off the earth...
extension CLLocationCoordinate2D: RandomGeneratable {
    static func random() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: Double.random(), longitude: Double.random())
    }
    
    func random() -> CLLocationCoordinate2D {
        let randomLat = self.latitude.random()
        let randomLon = self.longitude.random()
        return CLLocationCoordinate2D.init(latitude: randomLat, longitude: randomLon)
    }
}

extension Date: RandomGeneratable {
    static func random() -> Date {
        return Date.distantFuture.random()
    }
    
    func random() -> Date {
        return Date.init(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate.random())
    }
}

extension RouteEntry: RandomGeneratable {
    static func random() -> RouteEntry {
        return RouteEntry.init(WithTime: Date.random(), AndLocation: CLLocationCoordinate2D.random())
    }
    
    func random() -> RouteEntry {
        return RouteEntry.init(
            WithTime: time.random(),
            AndLocation: location.random()
        )
    }
}

extension String: RandomGeneratable {
    static func random() -> String {
        return UUID.init().uuidString
    }
    
    func random() -> String {
        return String.random()
    }
}

extension RouteMetaData: RandomGeneratable {
    static func random() -> RouteMetaData {
        let endDate = Date.random()
        let startDate = endDate.random()
        
        return RouteMetaData.init(
            WithId: String.random(),
            StartTime: startDate ,
            EndTime: endDate,
            Distance: Int.random()
        )
    }
    
    func random() -> RouteMetaData {
        return RouteMetaData.random()
    }
}

extension Route: RandomGeneratable {
    static func random() -> Route {
        // Note that this uses the random(ForCount) method for generating an array of random values
        return Route.init(
            WithRouteMetaData: RouteMetaData.random(),
            AndPath: RouteEntry.random(ForCount: 10)
        )
    }
    
    func random() -> Route {
        // This does the same but generates an array of paths of the same length as the current Rout
        let metaData = RouteMetaData.random()
        let randomEntries = RouteEntry.random().random(ForCount: self.path.count)
        return Route.init(WithRouteMetaData: metaData, AndPath: randomEntries)
    }
}
