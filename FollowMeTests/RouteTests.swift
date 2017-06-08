//
//  RouteTests.swift
//  FollowMe
//
//  Created by Andrew on 08/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation
import XCTest
import EVReflection
@testable import FollowMe

class RouteTestCast: XCTestCase {
    func testCanSerializeAndDeserializeRouteEntry() {
        let latitude = -53.0
        let longitude = 23.0
        let time = Date()
        let timeFormatter = DateFormatter.init()
        timeFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let entry = RouteEntry.init(WithTime:time, AndLocation: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude))
        let entryString = entry.serializable.toJsonString()
        print(entryString)
        
        // what if this is garbage string?
        let deserializedRelfectionEntry = SerializableRouteEntry(json: entryString)
        
        let deserializedEntry = RouteEntry.init(FromSerializable: deserializedRelfectionEntry)
        
        XCTAssert(
            deserializedEntry.location.latitude == entry.location.latitude,
            "Latitudes do not match"
        )
        
        XCTAssert(
            deserializedEntry.location.longitude == entry.location.longitude,
            "Longitudes do not match"
        )
        
        
        let deserializedTime = timeFormatter.string(from: deserializedEntry.time)
        let originalTime = timeFormatter.string(from: entry.time)
        XCTAssert(
            deserializedTime == originalTime,
            "Timeintervals do not match"
        )                        
    }
}
