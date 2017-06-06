//
//  LocationUpdatedInteractor.swift
//  FollowMe
//
//  Created by Andrew on 06/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

@objc class LocationUpdatedInteractor: NSObject {
    
    var locationUpdated: LocationUpdatedListener {
        return {
            (newLocationReceived) in
            return
        }
    }
    
    var locationUsage: LocationUsage {
        return IN_APP;
    }
    
}
