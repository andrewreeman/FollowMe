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

// ruby like!
// can do 5.times { print("hello \($0)")}
extension Int {
    func times(_ f: (Int) -> ()) {
        for i: Int in 0..<self {
            f(i)
        }
    }
    
    func times(_ f: () -> ()) {
        self.times { (_:Int) in
            f()
        }
    }
    
    func map<T>(_ f: (Int) -> T) -> [T]{
        var collection = [T]()
        
        self.times { (i: Int) in
            let mapped: T = f(i)
            collection.append(mapped)
        }
        return collection
    }
}

extension Int {
    func min(_ lowerBound: Int) -> Int {
        return Swift.min(self, lowerBound)
    }
}

extension Double {
    func min(_ lowerBound: Double) -> Double {
        return Swift.min(self, lowerBound)
    }
}
