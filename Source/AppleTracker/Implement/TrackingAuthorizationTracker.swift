//
//  TrackingAuthorizationTracker.swift
//  SabyAppleTracker
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class TrackingAuthorizationTracker: Tracker {
    public typealias Value = Promise<TrackingAuthorization, Error>
    
    private let tracker: TrackerReflection
    
    public init?() {
        guard let tracker = TrackerReflection() else {
            return nil
        }
        
        self.tracker = tracker
    }
    
    public func track() -> Promise<TrackingAuthorization, Error> {
        Promise.async {
            try self.tracker.track()
        }
    }
}

public enum TrackingAuthorization: UInt {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
}

private final class TrackerReflection {
    private let classTracker: NSObjectClass
    private let methodTrackCode: NSObjectClassMethod
    
    init?() {
        guard
            let classTracker = (
                NSObjectClass(name: "ATTrackingManager")
            ),
            let methodTrackCode = (
                classTracker.method(name: "trackingAuthorizationStatus")
            )
        else {
            return nil
        }
        
        self.classTracker = classTracker
        self.methodTrackCode = methodTrackCode
    }
    
    func track() throws -> TrackingAuthorization {
        guard
            let code = classTracker.call(methodTrackCode, return: .value(UInt.self)),
            let trackingAuthorization = TrackingAuthorization(rawValue: code)
        else {
            throw TrackingAuthorizationTrackerError.unmatchedType
        }
        
        return trackingAuthorization
    }
}

public enum TrackingAuthorizationTrackerError: Error {
    case unmatchedType
}

#endif
