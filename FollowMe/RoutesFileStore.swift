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
 
 Because this class contains multi-threading I have used a convention of prefixing most private methods with '_' to indicate that these are private and will not directly use the FILE_QUEUE. Most of the public methods will use this queue.
 As long as all methods only interact with private methods then no deadlocking will occur!
 Because we will be performing async work we will use a callback to inform when file changes have been made.
 We use the 'performAsync' private method to put items on the queue and trigger the callback along with any errors after every transaction.
*/

/**
 The types of transactions the listener will be told happened
*/
enum RouteFileStoreTransactionType {
    case delete
    case update
}

/**
 The directory the rotues will be kept in
*/
fileprivate let ROUTES_DIR = DOCUMENT_DIR.appendingPathComponent("Routes").createFileURL()!
class RoutesFileStore {
    typealias RouteFileStoreUpdated = (RouteFileStoreTransactionType, RoutesFileStore, Error?) -> ()
    
    /** This is the queue we will use for writing files async. 
     We have tried to take care that no deadlocks occur by prefixing 'safe' methods with '_'
     */
    private static let FILE_QUEUE = DispatchQueue.init(
        label: "com.stepwise.followme.filequeue", qos: DispatchQoS.utility
    )
    
    /**
     When files have been deleted, created or updated then this listener is called
    */
    private var m_updatedListener: RouteFileStoreUpdated?
    var updatedListener: RouteFileStoreUpdated? {
        get {
            return m_updatedListener
        }
        set {
            m_updatedListener = newValue
        }
    }
    
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
        return try RoutesFileStore.FILE_QUEUE.sync {
            return try _loadAllRoutes().map{ $0.routeMetaData }
        }
    }
    
    /**
     Using the id in the routemetadata this will obtain the route
    */
    func getRouteFor(RouteMetaData metaData: RouteMetaData) -> Route? {
        return RoutesFileStore.FILE_QUEUE.sync {
            guard let serializableRoute = _loadRoute(FromUrl: metaData.url ) else { return nil }
            return Route(FromSerializable: serializableRoute)
        }
    }
    
    /**
     Writes the route to disk
    */
    func update(Route: Route) {
        performAsync(TransactionType: .update) {
            [weak self] in
            try self?._create(route: Route)
        }
    }
    
    /**
     Deletes a route
    */
    func delete(Route: Route) {
        performAsync(TransactionType: .delete) {
            [weak self] in
            try self?._delete(Route: Route)
        }
    }
    
    func clearAllRoutes() throws {
        performAsync(TransactionType: .delete) {
            [weak self] in
            try self?._loadAllRoutes().forEach{ try self?._delete(Route: $0) }
        }
    }
    
    // MARK: private methods
    
    private func performAsync(
        
        TransactionType: RouteFileStoreTransactionType,
        _  transaction: @escaping () throws -> ()
        )
    {
        /**
         Performs the transaction async on the FILE_QUEUE.
         If the transaction succeeds then the listener is triggered with the transaction type.
         If it fails then the same happens but an error is passed through.
         */
        
        RoutesFileStore.FILE_QUEUE.async {
            [weak self] in
            guard let this = self else { return }
            
            do {
                try transaction()
                this.m_updatedListener?(TransactionType, this, nil)
            } catch {
                this.m_updatedListener?(TransactionType, this, error)
            }
        }
    }

    
    private func _delete(Route: Route) throws {
        try FileManager.default.removeItem(at: Route.dir)
    }    
    
    private func _create(route: Route) throws {
        try route.serializable.toJsonString().write(to: route.url, atomically: true, encoding: .utf8)
    }
    
    private func _loadRoute(FromUrl: URL) -> SerializableRoute? {
        guard let jsonString = try? String.init(contentsOf: FromUrl) else { return nil }
        return SerializableRoute(json: jsonString)
    }
    
    private func _loadAllRoutes() throws -> [Route] {
        /**
         This iterates through every Route folder. For each folder it then finds the json file then loads this as a route.
         Using flatmap will take care of skipping over any nil values in the list and also stripping any nil values returned from the map.
        */
        
        let fm = FileManager.default
        return try fm.contentsOfDirectory( at: ROUTES_DIR )
        .flatMap{  (routeDir: URL) -> Route? in
            guard let directoryContents = try? fm.contentsOfDirectory(at: routeDir) else { return nil }
            
            let route = directoryContents
            .filter{ $0.pathExtension == "json" }.first
            .flatMap { (routeFile) -> Route? in
                guard let serializableRoute = _loadRoute(FromUrl: routeFile) else { return nil }
                return Route(FromSerializable: serializableRoute)
            }
            return route
        }
    }
}

// These are utility properties for route and the meta data that are used just for the routesfilestore
fileprivate extension Route {
    var url: URL { return self.routeMetaData.url }
    var dir: URL { return self.routeMetaData.dir }
    var fileExists: Bool { return self.routeMetaData.fileExists }
}

fileprivate extension RouteMetaData {
    private var fileName: String {
        return "\(self.id).json"
    }
    
    var url: URL {
        makeDirIfNeeded( dir )
        return dir.appendingPathComponent(self.fileName)
    }
    
    var dir: URL {
        return ROUTES_DIR.appendingPathComponent(self.id)
    }
    
    var fileExists: Bool {
        return FileManager.default.fileExists(atPath: self.url.path)
    }
    
    private func makeDirIfNeeded(_ thisRoutesDir: URL ) {
        easyTry {
            guard !FileManager.default.fileExists(atPath: thisRoutesDir.path) else { return }
            try FileManager.default.createDirectory(
                at: thisRoutesDir, withIntermediateDirectories: true, attributes: nil
            )
        }
    }
}
