//
//  RoutesFileStore.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation


/**
 This is the file repository that is used for routes. At the time of writing (06-08-2017) this has not been completed.
 The structure for the file repository is:
    Routes/
        {RouteIdA}/{RouteIdA}.json
        {RouteIdB}/{RouteIdB}.json
*/
class RoutesFileStore {
    /** This is the queue we will use for writing files async */
    private static let FILE_QUEUE = DispatchQueue.init(label: "com.stepwise.followme.filequeue")
    private static let ROUTES_DIR = DOCUMENT_DIR.appendingPathComponent("Routes")
    
    /**
     Swift tip! This is a failable initializer. It will return nil if directory creation fails.
    */
    init?() {
        let fm = FileManager.default
        
        do {
            try fm.createDirectory(at: RoutesFileStore.ROUTES_DIR, withIntermediateDirectories: true, attributes: nil)
        } catch {
            DebugLog.instance.error(Message: "\(error)")
            return nil
        }
    }
    
    // MARK: public methods
    
    // Create a route file. Should probably just use update instead...
    func create(Route: Route){
        
    }
    
    /**
     This is used for displaying the route entries in a list picker.
     */
    func retrieveRouteMetaData() -> [RouteMetaData] {
        return [RouteMetaData]()
    }
    
    /**
     Using the id in the routemetadata this will obtain the route
    */
    func getRouteFor(RouteMetaData: RouteMetaData) -> Route {
        return Route()
    }
    
    /**
     Writes the route to disk
    */
    func update(Route: Route) {
        
    }
    
    /**
     Deletes a route along with it's containing folder
    */
    func delete(Route: Route) {
        
    }
    
    // MARK: private methods
    private func fileName(ForRoute: Route) -> String {
        return "\(ForRoute.routeMetaData.id).json"
    }
    
}
