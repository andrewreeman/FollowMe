//
//  Common.swift
//  FollowMe
//
//  Created by Andrew on 06/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

infix operator ?=: AssignmentPrecedence

// Optional assignment: only assign if left is nil
func ?=<T>(left: inout T?, right: T?) {
    if left == nil {
        left = right!
    }
}

infix operator =?: AssignmentPrecedence

// Optional assignment: only assign if right is not nil
func =?<T>(left: inout T, right: T?) {
    if right != nil {
        left = right!
    }
}

extension CLLocationCoordinate2D {
    var clLocation: CLLocation {
        return CLLocation.init(latitude: self.latitude, longitude: self.longitude)
    }
    
    func distance(From: CLLocationCoordinate2D) -> CLLocationDistance {
        return self.clLocation.distance(from: From.clLocation)
    }
    
    
}
