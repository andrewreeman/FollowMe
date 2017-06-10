//
//  SelectedUseRouteViewController.swift
//  FollowMe
//
//  Created by Andrew on 10/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation
import UIKit

class SelectedUserRouteViewController: UIViewController {
    
    private var m_route: Route?
    var route: SerializableRoute? {
        get {
            return m_route?.serializable
        }
        set {
            guard let serializableNewValue = newValue else { return }
            m_route = Route.init(FromSerializable: serializableNewValue)
        }
    }
    
    private let m_mapApi = MapApi.init()
    
    override func viewDidLoad() {
        if let route = m_route {
            let map = m_mapApi.createMap(WithFrame: self.view.frame, AndRoute: route)
            map.center = self.view.center
        
            self.view.addSubview(map)
            self.view.sendSubview(toBack: map)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if m_route == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func backTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
