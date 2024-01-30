//
//  IdentifierForAdvertiserTracker.swift
//  SabyAppleTracker
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class IdentifierForAdvertiserTracker: Tracker {
    public typealias Value = Promise<IdentifierForAdvertiser, Error>
    
    private let tracker: TrackerReflection
    
    public init?() {
        guard let tracker = TrackerReflection() else {
            return nil
        }
        
        self.tracker = tracker
    }
    
    public func track() -> Promise<IdentifierForAdvertiser, Error> {
        Promise.async {
            try self.tracker.track()
        }
    }
}

public struct IdentifierForAdvertiser {
    public let identifier: String
    public let limitAdTracking: Bool
}

private final class TrackerReflection {
    private let classTracker: NSObjectClass
    private let methodShared: NSObjectClassMethod
    private let instanceTracker: NSObjectInstance
    private let methodTrackIdentifier: NSObjectInstanceMethod
    private let methodTrackLimitAdTracking: NSObjectInstanceMethod
    
    init?() {
        guard
            let classTracker = (
                NSObjectClass(name: "ASIdentifierManager")
            ),
            let methodShared = (
                classTracker.method(name: "sharedManager")
            ),
            let instanceTracker = (
                classTracker.instance(object: classTracker.call(methodShared, return: .reference))
            ),
            let methodTrackIdentifier = (
                instanceTracker.method(name: "advertisingIdentifier")
            ),
            let methodTrackLimitAdTracking = (
                instanceTracker.method(name: "advertisingTrackingEnabled")
            )
        else {
            return nil
        }
        
        self.classTracker = classTracker
        self.methodShared = methodShared
        self.instanceTracker = instanceTracker
        self.methodTrackIdentifier = methodTrackIdentifier
        self.methodTrackLimitAdTracking = methodTrackLimitAdTracking
    }
    
    func track() throws -> IdentifierForAdvertiser {
        guard
            let limitAdTracking = instanceTracker.call(methodTrackLimitAdTracking, return: .value(Bool.self)),
            let identifier = instanceTracker.call(methodTrackIdentifier, return: .reference(UUID.self))
        else {
            throw IdentifierForAdvertiserTrackerError.unmatchedType
        }
        
        return IdentifierForAdvertiser(
            identifier: identifier.uuidString,
            limitAdTracking: limitAdTracking
        )
    }
}

public enum IdentifierForAdvertiserTrackerError: Error {
    case unmatchedType
}

#endif
