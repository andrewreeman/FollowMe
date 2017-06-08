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

class RouteTestCase: XCTestCase {
    func testCanSerializeAndDeserializeRouteEntry() {
        
        let entry = RouteEntry.random()
        let entryString = entry.serializable.toJsonString()
        print(entryString)
        
        // what if this is garbage string?
        let deserializedRelfectionEntry = SerializableRouteEntry(json: entryString)
        
        let deserializedEntry = RouteEntry.init(FromSerializable: deserializedRelfectionEntry)
        XCTAssert(entry == deserializedEntry, "Entries are not equal: \(entry) \(deserializedEntry)")
    }
    
    func testCanSerializeAndDeserializeRouteMetaData() {
        var routeMetaData = RouteMetaData.random()        
        Thread.sleep(forTimeInterval: 10.random().min(2))
        routeMetaData = routeMetaData.completeRoute()
        
        let jsonString = routeMetaData.serializable.toJsonString()
        print(jsonString)
        
        let serializableMetaData = SerializableRouteMetaData(json: jsonString)
        let deserializedMetaData = RouteMetaData.init(FromSerializable: serializableMetaData)
        XCTAssert(routeMetaData == deserializedMetaData, "MetaData are not equal: \(routeMetaData). \(deserializedMetaData)")
    }
    
    func testCanSerializeAndDeserializeRoute() {
        let route = Route.random()
        let jsonString = route.serializable.toJsonString()
        print(jsonString)
        
        let deserializedRoute = Route.init(FromSerializable: SerializableRoute(json: jsonString))
        XCTAssert(route == deserializedRoute, "Routes are not equal: \(route). \(deserializedRoute)")
    }
    
    
    
    
}
