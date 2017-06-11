 //
//  RouteTableDelegate.swift
//  FollowMe
//
//  Created by Andrew on 10/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation
import UIKit

/**
  This will generate the table data and the table cells. It will speak to the RouteTableViewController whenever the dataset changes
*/
 
/**
  This provides the same function as the LocationDelegateMessagePresenter. It is simply anything that can present a message from the RouteTableDelegate. We will use it for confirmation of deletion and renaming.
*/
@objc protocol RouteTableMessagePresenter: class {
    func present(Alert: UIAlertController)
}

/**
  The type of datsource modifications that can occur.
*/
@objc enum RouteDataSourceAction: Int {
    case routeDeleted
    case routeSelected
    case routeRenamed
}
 
@objc class RouteTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private var m_routes = [RouteMetaData]()
    private var m_routesFileStore: RoutesFileStore?
    
    // This listener will be told whenever the data source changes. 
    // We are passing a serializable route because that is the only obj-c compatable route type
    // Ideally we would pass a Route but we do not want to bloat this class with being an NSObject
    typealias RouteDataSourceObjCListener = (RouteDataSourceAction, SerializableRoute) -> ()
    
    private var m_objCRouteDataSourceListener: RouteDataSourceObjCListener
    private let m_presenter: RouteTableMessagePresenter
    
    @objc init(
        WithPresenter: RouteTableMessagePresenter,
        AndDataSourceListener: @escaping RouteDataSourceObjCListener
    )
    {
        m_routesFileStore = RoutesFileStore.init()
        m_objCRouteDataSourceListener = AndDataSourceListener
        
        // only set the route if we actually retreive any routes!
        m_routes =? m_routesFileStore.flatMap{ try? $0.retrieveRouteMetaData() }
        m_presenter = WithPresenter
        super.init()
        
        // Informing the RouteTableViewController when renaming and deletion occurs
        m_routesFileStore?.updatedListener = {
            [weak self]
            (transaction, route, error) in
            
            switch (transaction, route) {
            case (.delete, .some(let r)) :
                self?.m_objCRouteDataSourceListener(.routeDeleted, r.serializable)
            case (.update, .some(let r)):
                self?.m_objCRouteDataSourceListener(.routeRenamed, r.serializable)
            default: break
            }
        }
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
        cell.detailTextLabel?.text = "\(route.distanceInMeters)m. \(route.durationInSeconds)s"
        
                       
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // This is where we make use the presenter to present messages
        
        guard let route = m_routes[safe: indexPath.row] else { return }
        
        let alert = UIAlertController.init(
            title: route.displayName, message: "", preferredStyle: .actionSheet
        )
        
        let cancel = UIAlertAction.init(title: "cancel".localized, style: .cancel, handler: nil)
        let delete = UIAlertAction.init(title: "delete".localized, style: .destructive) { (_) in
            self.confirmDelete(Route: route)
        }
        
        let rename = UIAlertAction.init(title: "rename".localized, style: .default) { (_) in
            self.confirmRename(Route: route)
        }
        
        [rename, delete, cancel].forEach{ alert.addAction($0) }
        
        m_presenter.present(Alert: alert)
    }
    
    // MARK: delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {                
        guard let routeMetaData = m_routes[safe: indexPath.row]
        else { return }
        
        guard let route = m_routesFileStore?.getRouteFor(RouteMetaData: routeMetaData)
        else { return }
        
        m_objCRouteDataSourceListener(.routeSelected, route.serializable)
    }
        
    // public methods 
    func reloadData() {
        m_routes =? m_routesFileStore.flatMap{ try? $0.retrieveRouteMetaData() }
    }
    
    // MARK: private methods
    private func confirmDelete(Route routeMetaData: RouteMetaData) {
        let message = String.init(format: "deleteConfirm".localized, routeMetaData.displayName)
        
        let confirmDeleteAlert = UIAlertController.init(
            title: "delete".localized,
            message: message,
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction.init(title: "cancel".localized, style: .cancel, handler: nil)
        let ok = UIAlertAction.init(title: "ok".localized, style: .destructive) { (_) in
            if let route = self.m_routesFileStore?.getRouteFor(RouteMetaData: routeMetaData) {
                self.m_routesFileStore?.delete(Route: route)
            }
        }
        
        confirmDeleteAlert.addAction(cancel)
        confirmDeleteAlert.addAction(ok)
        
        m_presenter.present(Alert: confirmDeleteAlert)
    }
    
    private func confirmRename(Route routeMetaData: RouteMetaData) {
        let message = String.init(format: "renameConfirm".localized, routeMetaData.displayName)
        let confirmRenameAlert = UIAlertController.init(
            title: "rename".localized, message: message, preferredStyle: .alert
        )
        
        confirmRenameAlert.addTextField {
            $0.keyboardType = UIKeyboardType.alphabet
        }
        let cancel = UIAlertAction.init(title: "cancel".localized, style: .cancel, handler: nil)
        let ok = UIAlertAction.init(title: "ok".localized, style: .destructive) { (_) in
            guard let nameField = confirmRenameAlert.textFields?.first
            else { return }
            
            guard let newName = nameField.text else { return }
            guard !newName.isEmpty else { return }
            
            
            if let route = self.m_routesFileStore?.getRouteFor(RouteMetaData: routeMetaData) {
                route.set(Name: newName)
                self.m_routesFileStore?.update(Route: route)
            }
        }
        
        confirmRenameAlert.addAction(cancel)
        confirmRenameAlert.addAction(ok)
        
        m_presenter.present(Alert: confirmRenameAlert)        
    }
}
