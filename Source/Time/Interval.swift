//
//  TimeIntervalConvert.swift
//  SabyTime
//
//  Created by WOF on 2022/08/19.
//

import Foundation

public struct Interval: Equatable {
    private let interval: TimeInterval
    
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
        .milliseconds({
            let millisecond = Int64(self.millisecond)
            if millisecond < Int.min {
                return Int.min
            }
            else if Int.max < millisecond {
                return Int.max
            }
            else {
                return Int(millisecond)
            }
        }())
    }
}
