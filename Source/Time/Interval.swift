//
//  Interval.swift
//  SabyTime
//
//  Created by WOF on 2022/08/19.
//

import Foundation

public struct Interval: Codable, Comparable, Equatable {
    let interval: TimeInterval
    
    public init(second: TimeInterval) {
        self.interval = second
    }
}

extension Interval {
    public static func millisecond(_ millisecond: Double) -> Interval {
        Interval(second: millisecond / 1000)
    }
    
    public static func second(_ second: Double) -> Interval {
        Interval(second: second)
    }
    
    public static func minute(_ minute: Double) -> Interval {
        Interval(second: minute * 60)
    }
    
    public static func hour(_ hour: Double) -> Interval {
        Interval(second: hour * 60 * 60)
    }
    
    public static func day(_ day: Double) -> Interval {
        Interval(second: day * 24 * 60 * 60)
    }
}

extension Interval {
    public static func +(left: Interval, right: Interval) -> Interval {
        Interval(second: left.interval + right.interval)
    }
    
    public static func -(left: Interval, right: Interval) -> Interval {
        Interval(second: left.interval - right.interval)
    }
    
    public static func <(left: Interval, right: Interval) -> Bool {
        left.interval < right.interval
    }
}

extension Interval {
    public static func +(left: Interval, right: Timestamp) -> Timestamp {
        Timestamp(secondFrom1970: left.interval + right.timestamp)
    }
    
    public static func -(left: Interval, right: Timestamp) -> Timestamp {
        Timestamp(secondFrom1970: left.interval - right.timestamp)
    }
}

extension Interval {
    public var millisecond: Double {
        interval * 1000
    }
    
    public var second: Double {
        interval
    }
    
    public var minute: Double {
        interval / 60
    }
    
    public var hour: Double {
        interval / 60 / 60
    }
    
    public var day: Double {
        interval / 24 / 60 / 60
    }
}

extension Interval {
    public var time: TimeInterval {
        interval
    }
    
    public var dispatchTime: DispatchTimeInterval {
        .milliseconds(Int(millisecond))
    }
}
