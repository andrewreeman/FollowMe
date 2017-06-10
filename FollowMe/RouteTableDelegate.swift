 //
//  RouteTableDelegate.swift
//  FollowMe
//
//  Created by Andrew on 10/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation
import UIKit

@objc class RouteTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private var m_routes = [RouteMetaData]()
    private var m_routesFileStore: RoutesFileStore?
    
    typealias RouteSelectedObjCCallbackType = (SerializableRoute) -> ()
    
    private var m_objCRouteSelected: RouteSelectedObjCCallbackType?
    var objCRouteSelected: RouteSelectedObjCCallbackType? {
        get {
            return m_objCRouteSelected
        }
        set {
            m_objCRouteSelected = newValue
        }
    }
    
    override init() {
        m_routesFileStore = RoutesFileStore.init()
        m_routes =? m_routesFileStore.flatMap{ try? $0.retrieveRouteMetaData() }
    }
    
    // MARK: data source methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "route_cell")
            else { return UITableViewCell.init() }
        
        guard let route = m_routes[safe: indexPath.row] else { return cell }
        
        cell.textLabel?.text = route.displayName
        cell.detailTextLabel?.text = "\(route.distanceInMeters)m"
                       
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let route = m_routes[safe: indexPath.row] else { return }
        
        let alert = UIAlertController.init(
            title: route.displayName, message: "", preferredStyle: .actionSheet
        )
        
        let cancel = UIAlertAction.init(title: "cancel".localized, style: .cancel, handler: nil)
        let delete = UIAlertAction.init(title: "delete".localized, style: .destructive) { (_) in
            self.confirmDelete()
        }
        
    }
    
    // MARK: delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let callback = m_objCRouteSelected else { return }
        
        guard let routeMetaData = m_routes[safe: indexPath.row]
        else { return }
        
        guard let route = m_routesFileStore?.getRouteFor(RouteMetaData: routeMetaData)
        else { return }
        
        callback(route.serializable)
    }
    
    // public methods 
    func reloadData() {
        m_routes =? m_routesFileStore.flatMap{ try? $0.retrieveRouteMetaData() }
    }
    
    func confirmDelete() {
        
    }
}
