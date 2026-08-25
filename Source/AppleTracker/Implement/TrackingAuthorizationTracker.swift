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
        let tracker = self.tracker

        return Promise.async {
            try await tracker.track()
        }
    }
}

public enum TrackingAuthorization: UInt, Sendable {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
}

private actor TrackerReflection {
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
        
        self.methodTrackCode = methodTrackCode
    }
    
    func track() throws -> TrackingAuthorization {
        guard
            let code = {
                let function = unsafeBitCast(
                    methodTrackCode.implementation,
                    to: (@convention(c)(AnyClass, Selector)->UInt).self
                )
                return function(
                    methodTrackCode.anyClass,
                    methodTrackCode.selector
                )
            }(),
            let trackingAuthorization = TrackingAuthorization(rawValue: code)
        else {
            throw TrackingAuthorizationTrackerError.unmatchedType
        }
        
        return trackingAuthorization
    }
}

private enum TrackingAuthorizationTrackerError: Error {
    case unmatchedType
}

#endif
