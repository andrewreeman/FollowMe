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
    
    func testCanReadAndWriteRouteToDisk() {
        defer {
            do {
                try RoutesFileStore()?.clearAllRoutes()
            } catch {
                XCTFail("\(error)")
            }
        }
        
        let route = Route.random()
        guard let routeFileStore = RoutesFileStore()
        else {
            XCTFail("Could not create Route directory.")
            return
        }
        
        do {
            try routeFileStore.clearAllRoutes()
        
            routeFileStore.update(Route: route)
            let routeMetaDatas = try routeFileStore.retrieveRouteMetaData()
            
            guard let storedMetaData = routeMetaDatas.first
            else {
                XCTFail("Route meta data is empty. Could not load from disk?")
                return
            }
            
            guard let storedRoute = routeFileStore.getRouteFor(RouteMetaData: storedMetaData)
            else {
                XCTFail("Could not load stored route from meta data")
                return
            }
            
            XCTAssert(storedRoute == route,
                "Routes do not match: \(storedRoute) does not match \(route)"
            )
        } catch {
            XCTFail("Could not load route from disk: \(error)")
        }
    }
    
    func testCanListenerReceiveRoutesFileStoreChanges() {
        defer {
            do {
                try RoutesFileStore()?.clearAllRoutes()
            } catch {
                XCTFail("\(error)")
            }
        }
        
        let route = Route.random()
        guard let routeFileStore = RoutesFileStore()
            else {
                XCTFail("Could not create Route directory.")
                return
        }
        
        let e = expectation(description: "File ops performed ok")
        
        e.expectedFulfillmentCount = 2
        routeFileStore.updatedListener = {
            (transactionType, updatedRoute, error) in            
            guard error == nil
            else {
                XCTFail("\(error!)")
                return
            }
            
            guard let updatedRoute = updatedRoute
            else {
                XCTFail("Nil passed as route when performing simple update and delete")
                return
            }
            
            XCTAssert(route == updatedRoute, "Modified route does not match original route")
            switch transactionType {
            case .update:
                print("Updated: Fulfilling once")
                e.fulfill()
                routeFileStore.delete(Route: updatedRoute)
            case .delete:
                
                print("Deleted: Fulfilling twice")
                e.fulfill()
            }
        }
        
        routeFileStore.update(Route: route)
        
        waitForExpectations(timeout: 5) {
            if let error = $0 {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
