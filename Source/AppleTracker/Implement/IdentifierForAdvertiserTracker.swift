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
                classTracker.instance(object: {
                    let function = unsafeBitCast(
                        methodShared.implementation,
                        to: (@convention(c)(AnyClass, Selector)->Any?).self
                    )
                    return function(
                        methodShared.anyClass,
                        methodShared.selector
                    )
                }())
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
            let limitAdTracking = {
                let function = unsafeBitCast(
                    methodTrackLimitAdTracking.implementation,
                    to: (@convention(c)(NSObject, Selector)->Bool).self
                )
                return function(
                    methodTrackLimitAdTracking.object,
                    methodTrackLimitAdTracking.selector
                )
            }(),
            let identifier = {
                let function = unsafeBitCast(
                    methodTrackIdentifier.implementation,
                    to: (@convention(c)(NSObject, Selector)->UUID).self
                )
                return function(
                    methodTrackIdentifier.object,
                    methodTrackIdentifier.selector
                )
            }()
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
