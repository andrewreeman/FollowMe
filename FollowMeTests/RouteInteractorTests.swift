//
//  RouteInteractorTests.swift
//  FollowMe
//
//  Created by Andrew on 09/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation
import XCTest
@testable import FollowMe

class RouteInteractorTests: XCTestCase {
    func testDoesRouteInteractorCreateARouteFile() {
        defer {
            do {
                try RoutesFileStore()?.clearAllRoutes()
            } catch {
                XCTFail("\(error)")
            }
        }
        
        let routeInteractor = RouteInteractor.init()
        let locationUpdated = routeInteractor.locationUpdated
        let e = expectation(description: "That saved route matches route in memory")
        
        routeInteractor.routeUpdated = {
            (transactionType, updatedRoute, error) in
            guard let route = updatedRoute
            else {
                XCTFail("No route passed back")
                return
            }
            
            switch transactionType {
            case .update:
                if let loadedRoute = RoutesFileStore.init()?
                    .getRouteFor(
                        RouteMetaData: route.routeMetaData
                    )
                {
                    XCTAssert(
                        route == loadedRoute,
                        "Loaded route and passed route do not match"
                    )
                    e.fulfill()
                }
                else {
                    XCTFail("Could not load route")
                }
                
            default:
                break
            }
        }
        
        locationUpdated(CLLocationCoordinate2D.random().clLocation, TrackingState.TrackingOn)
        
        waitForExpectations(timeout: 5) {
            if let error = $0 {
                XCTFail("Received error: \(error.localizedDescription)")
            }
        }
    }
    
    func testCanRouteInteractorUpdateUi() {
        defer {
            do {
                try RoutesFileStore()?.clearAllRoutes()
            } catch {
                XCTFail("\(error)")
            }
        }
        
        let routeInteractor = RouteInteractor.init()
        let locationUpdated = routeInteractor.locationUpdated
        let e = expectation(description: "That route interactor updates the ui")
        
        e.expectedFulfillmentCount = 2
        
        let p1 = CLLocationCoordinate2D.random().clLocation
        let p2 = CLLocationCoordinate2D.random().clLocation
        routeInteractor.uiUpdateListener = {
            (location, trackingState ) in
            
            switch trackingState {
            case .TrackingOn:
                XCTAssert(
                    p1.coordinate.latitude == location.coordinate.latitude,
                    "Latitudes do not match"
                )
                XCTAssert(
                    p1.coordinate.longitude == location.coordinate.longitude,
                    "Longitudes do not match"
                )
                e.fulfill()
            case .TrackingOff:
                XCTAssert(
                    p2.coordinate.latitude == location.coordinate.latitude,
                    "Latitudes do not match"
                )
                XCTAssert(
                    p2.coordinate.longitude == location.coordinate.longitude,
                    "Longitudes do not match"
                )
                e.fulfill()
            default:
                XCTFail("Should not be any other tracking state except on or off")
            }
        }
        
        locationUpdated(p1, TrackingState.TrackingOn)
        locationUpdated(p2, TrackingState.TrackingOff)
        
        waitForExpectations(timeout: 5) {
            if let error = $0 {
                XCTFail("Received error: \(error.localizedDescription)")
            }
        }
    }
    
    func testTrackMultipleLocationsAndCompleteRoute() {
        defer {
            do {
                try RoutesFileStore()?.clearAllRoutes()
            } catch {
                XCTFail("\(error)")
            }
        }
        
        let routeInteractor = RouteInteractor.init()
        let locationUpdated = routeInteractor.locationUpdated
        let e = expectation(description: "That the stored route will have multiple locations")
        
        let locations = CLLocationCoordinate2D.random(ForCount: 30.random() + 5).map{$0.clLocation}
        var mutableLocations:[CLLocation] = locations.reversed()
        
        
        routeInteractor.routeUpdated = {
            (transactionType, updatedRoute, error) in
            guard let route = updatedRoute
                else {
                    XCTFail("No route passed back")
                    return
            }
            
            print("👍🏽 Route updated: \(route)")
            switch transactionType {
            case .update:
                if let loadedRoute = RoutesFileStore.init()?
                    .getRouteFor(
                        RouteMetaData: route.routeMetaData
                    )
                {
                    print("👍🏽 loaded route")
                    XCTAssert(
                        route == loadedRoute,
                        "Loaded route and passed route do not match: \(route) \n\n comparised ot: \(loadedRoute)"
                    )
                    print("👍🏽 Routes as the same")
                    
                    if loadedRoute.routeMetaData.isComplete {
                        print("👍🏽 route complete ")
                        XCTAssert(
                            loadedRoute.path.count == locations.count,
                            "Route does not contain same number of entires as locations: Route entry count is: \(loadedRoute.path.count) and locations count is: \(locations.count)"
                        )
                        
                        let locationsAreEqual = zip(loadedRoute.path, locations).reduce(true, {
                            $0 && $1.0.location.latitude == $1.1.coordinate.latitude && $1.0.location.longitude == $1.1.coordinate.longitude
                        })
                        XCTAssert(locationsAreEqual, "Loaded path and locations are not equal")
                        e.fulfill()
                    }
                    else if let nextLocation = mutableLocations.popLast() {
                        let newTrackingState = mutableLocations.isEmpty
                            ? TrackingState.TrackingOff : TrackingState.TrackingOn
                        print("👍🏽 Updating next location ")
                        locationUpdated(nextLocation, newTrackingState)
                    }
                    else {
                        XCTFail("Route not complete but locations are empty")
                    }
                }
                else {
                    print("Route not loaded")
                    XCTFail("Could not load route")
                }
                
                
            default:
                break
            }
        }
        
        locationUpdated(mutableLocations.popLast()!, TrackingState.TrackingOn)
        
        waitForExpectations(timeout: 5) {
            if let error = $0 {
                XCTFail("Received error: \(error.localizedDescription)")
            }
        }

    }
}
