//
//  RoutesFileStore.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

class RoutesFileStore {
    private static let FILE_QUEUE = DispatchQueue.init(label: "com.stepwise.followme.filequeue")
    private static let ROUTES_DIR = DOCUMENT_DIR.appendingPathComponent("Routes")
    
    init?() {
        let fm = FileManager.default
        
        do {
            try fm.createDirectory(at: RoutesFileStore.ROUTES_DIR, withIntermediateDirectories: true, attributes: nil)
        } catch {
            DebugLog.instance.error(Message: "\(error)")
            return nil
        }
    }
    
    func create(Route: Route){
        
    }
    
    /**
     This is used for displaying the route entries in a list picker.
     */
    func retrieveRouteMetaData() -> [RouteMetaData] {
        return [RouteMetaData]()
    }
    
   /* func getRouteFor(RouteMetaData: RouteMetaData) -> Route {
        return Route()
    }*/
    
    func update(Route: Route) {
        
    }
    
    func delete(Route: Route) {
        
    }
    
    private func fileName(ForRoute: Route) -> String {
        return ForRoute.routeMetaData.id
    }
    
    
    
    
}
