//
//  TrackerProtocol.swift
//  SabyAppleTracker
//
//  Created by WOF on 11/1/23.
//

import Foundation

extension Tracker {
    public typealias SelfProtocol = Tracker<Self.Value>
    public typealias AnyProtocol = any Tracker<Self.Value>
}
