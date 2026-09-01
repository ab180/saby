//
//  Tracker.swift
//  SabyAppleTracker
//
//  Created by WOF on 11/1/23.
//

import Foundation

public protocol Tracker<Value>: Sendable {
    associatedtype Value
    
    func track() -> Value
}
