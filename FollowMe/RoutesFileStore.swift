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

fileprivate let ROUTES_DIR = DOCUMENT_DIR.appendingPathComponent("Routes").createFileURL()!
class RoutesFileStore {
    /** This is the queue we will use for writing files async */
    private static let FILE_QUEUE = DispatchQueue.init(label: "com.stepwise.followme.filequeue")
    
    /**
     Swift tip! This is a failable initializer. It will return nil if directory creation fails.
    */
    init?() {
        let fm = FileManager.default
        
        do {
            try fm.createDirectory(at: ROUTES_DIR, withIntermediateDirectories: true, attributes: nil)
        } catch {
            DebugLog.instance.error(Message: "\(error)")
            return nil
        }
    }
    
    // MARK: public methods
    
    /**
     This is used for displaying the route entries in a list picker.
     */
    func retrieveRouteMetaData() throws -> [RouteMetaData] {
        return try loadAllRoutes().map{ $0.routeMetaData }
    }
    
    /**
     Using the id in the routemetadata this will obtain the route
    */
    func getRouteFor(RouteMetaData metaData: RouteMetaData) -> Route? {
        guard let serializableRoute = loadRoute(FromUrl: metaData.url ) else { return nil }
        return Route(FromSerializable: serializableRoute)
    }
    
    /**
     Writes the route to disk
    */
    func update(Route: Route) {
        easyTry {
            try create(route: Route)
        }
    }
    
    /**
     Deletes a route along with it's containing folder
    */
    func delete(Route: Route) throws {
        try FileManager.default.removeItem(at: Route.url)
    }
    
    func clearAllRoutes() throws {
        try loadAllRoutes().forEach{ try delete(Route: $0) }
    }
    
    // MARK: private methods
    private func create(route: Route) throws {
        try route.serializable.toJsonString().write(to: route.url, atomically: true, encoding: .utf8)
    }
    
    private func loadRoute(FromUrl: URL) -> SerializableRoute? {
        guard let jsonString = try? String.init(contentsOf: FromUrl) else { return nil }
        return SerializableRoute(json: jsonString)
    }
    
    private func loadAllRoutes() throws -> [Route] {
        return try FileManager.default
        .contentsOfDirectory(
            at: ROUTES_DIR,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        .flatMap{
            guard let serializableRoute = loadRoute(FromUrl: $0) else { return nil }
            return Route(FromSerializable: serializableRoute)
        }
    }
}

// These are utility properties for route that are used just for the routesfilestore
fileprivate extension Route {
    var filename: String { return self.routeMetaData.fileName }
    var url: URL { return self.routeMetaData.url }
    var fileExists: Bool { return self.routeMetaData.fileExists }
}

fileprivate extension RouteMetaData {
    var fileName: String {
        return "\(self.id).json"
    }
    
    var url: URL {
        return ROUTES_DIR.appendingPathComponent(self.fileName)
    }
    
    var fileExists: Bool {
        return FileManager.default.fileExists(atPath: self.url.path)
    }
}
