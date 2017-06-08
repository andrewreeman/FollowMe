//
//  RandomGeneratable.swift
//  FollowMe
//
//  Created by Andrew on 08/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

protocol RandomGeneratable {
    static func random() -> Self
    func random() -> Self
}

extension RandomGeneratable {
    func random(ForCount: Int) -> [Self] {
        return ForCount.map{(_) in self.random()}
    }
}

extension Double: RandomGeneratable {
    static func random() -> Double {
        return Double(arc4random())
    }
    
    
    func random() -> Double {
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

extension Int: RandomGeneratable {
    static func random() -> Int {
        return Int.max.random()
    }
    
    func random() -> Int {
        return Int(Double(self).random())
    }
}

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
        return Date.distantPast.random()
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
        return Route.init(
            WithRouteMetaData: RouteMetaData.random(),
            AndPath: RouteEntry.random().random(ForCount: 10)
        )
    }
    
    func random() -> Route {
        let metaData = RouteMetaData.random()
        let randomEntries = RouteEntry.random().random(ForCount: self.path.count)
        return Route.init(WithRouteMetaData: metaData, AndPath: randomEntries)
    }
}
