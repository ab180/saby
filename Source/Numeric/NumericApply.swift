//
//  NumericApply.swift
//  SabyNumeric
//
//  Created by WOF on 2022/08/19.
//

import Foundation

extension Numeric where Self: Comparable {
    public func applied(limit: ClosedRange<Self>) -> Self {
        applied(minimum: limit.lowerBound, maximum: limit.upperBound)
    }
    
    public func applied(minimum: Self, maximum: Self) -> Self {
        if self < minimum {
            return minimum
        }
        else if maximum < self {
            return maximum
        }
        else {
            return self
        }
    }
    
    public func applied(limit: PartialRangeThrough<Self>) -> Self {
        applied(maximum: limit.upperBound)
    }
    
    public func applied(maximum: Self) -> Self {
        if maximum < self {
            return maximum
        }
        
        return self
    }
    
    public func applied(limit: PartialRangeFrom<Self>) -> Self {
        applied(minimum: limit.lowerBound)
    }
    
    public func applied(minimum: Self) -> Self {
        if self < minimum {
            return minimum
        }
        
        return self
    }
}
