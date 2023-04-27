//
//  Timestamp.swift
//  SabyTime
//
//  Created by WOF on 2022/08/19.
//

import Foundation

public struct Timestamp: Comparable, Equatable {
    let timestamp: TimeInterval
    
    public init(secondFrom1970 second: TimeInterval) {
        self.timestamp = second
    }
}

extension Timestamp {
    public static func now() -> Timestamp {
        Timestamp(secondFrom1970: Date().timeIntervalSince1970)
    }
}

extension Timestamp {
    public static func -(left: Timestamp, right: Timestamp) -> Interval {
        Interval(second: left.timestamp - right.timestamp)
    }
    
    public static func <(left: Timestamp, right: Timestamp) -> Bool {
        left.timestamp < right.timestamp
    }
}

extension Timestamp {
    public static func +(left: Timestamp, right: Interval) -> Timestamp {
        Timestamp(secondFrom1970: left.timestamp + right.interval)
    }
    
    public static func -(left: Timestamp, right: Interval) -> Timestamp {
        Timestamp(secondFrom1970: left.timestamp - right.interval)
    }
}

extension Timestamp {
    public var millisecondFrom1970: Double {
        timestamp * 1000
    }
    
    public var secondFrom1970: Double {
        timestamp
    }
    
    public var minuteFrom1970: Double {
        timestamp / 60
    }
    
    public var hourFrom1970: Double {
        timestamp / 60 / 60
    }
    
    public var dayFrom1970: Double {
        timestamp / 24 / 60 / 60
    }
}

extension Timestamp {
    public var timeFrom1970: TimeInterval {
        timestamp
    }
}
