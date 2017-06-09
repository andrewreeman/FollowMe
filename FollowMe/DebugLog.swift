//
//  DebugLog.swift
//  FollowMe
//
//  Created by Andrew on 07/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

import Foundation

/**
 * A simple debug log class that could be further expanded to writing the debug log to disk.
 * Probably using a library like 'SwiftyBeaver'
 * @see <a href="https://github.com/SwiftyBeaver/SwiftyBeaver">SwiftBeaver</a>
*/
class DebugLog {
    
    private static let s_debugLog = DebugLog()
    
    static var instance: DebugLog {
        return s_debugLog
    }
        
    private init() {}
    
    func error(Message: String, File: String = #file, Function: String = #function, Line: Int = #line) {
        print("Error: " + format(Message: Message, File: File, Function: Function, Line: Line))
    }
    
    private func format(Message: String, File: String, Function: String, Line: Int)-> String {
        return "In file \(File) -> using function \(Function) -> at line \(Line): \(Message)"
    }    
}
