//
//  Common.swift
//  FollowMe
//
//  Created by Andrew on 06/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

// Swift note: It is usually considered not best practice to define your own operators. This is probably ok for small projets or if the majority of the team agree on the operators.

// We are returning so that it essentially generates a compiler warning!
func easyTry(_ f: () throws -> ()) -> Bool {
    do {
        try f()
        return true
    } catch {
        print(error)
        return false
    }
}

// ruby like :)
extension Collection {
    var hasItems: Bool {
        return !self.isEmpty
    }
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}


// Optional assignment: only assign if left is nil
infix operator ?=: AssignmentPrecedence

func ?=<T>(left: inout T?, right: T?) {
    if left == nil {
        left = right
    }
}

// Optional assignment: only evaluation function and assign if left is nil
func ?=<T>(left: inout T?, right: () -> T?) {
    if left == nil {
        left = right()
    }
}

// Optional assignment: only assign if right is not nil
infix operator =?: AssignmentPrecedence

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
    
    // This is a (very swifty) useful function for creating a list N items. 
    // Can use like: 5.map{return "I am string number \($0)"}
    // This will create an array of 5 strings!
    func map<T>(_ f: (Int) -> T) -> [T]{
        var collection = [T]()
        
        self.times { (i: Int) in
            let mapped: T = f(i)
            collection.append(mapped)
        }
        return collection
    }
}

// these are to be used only by the most laziest of developers...
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


extension URL {
    func createFileURL() -> URL? {
        guard var sourceURLComponents = URLComponents.init(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        sourceURLComponents.scheme = "file"
        return sourceURLComponents.url
    }
}

extension FileManager {
    func contentsOfDirectory(at: URL) throws -> [URL] {
        return try self.contentsOfDirectory(at: at, includingPropertiesForKeys: nil)
    }    
}
