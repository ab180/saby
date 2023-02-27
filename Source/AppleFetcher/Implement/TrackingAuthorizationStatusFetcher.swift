//
//  TrackingAuthorizationStatusFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class TrackingAuthorizationStatusFetcher: Fetcher {
    public typealias Value = Promise<TrackingAuthorizationStatus, Error>
    
    private let classATTrackingManager: ClassATTrackingManager
    
    public init?() {
        guard let classATTrackingManager = ClassATTrackingManager() else { return nil }
        
        self.classATTrackingManager = classATTrackingManager
    }
    
    public func fetch() -> Promise<TrackingAuthorizationStatus, Error> {
        Promise {
            try self.classATTrackingManager.trackingAuthorizationStatus()
        }
    }
}

public enum TrackingAuthorizationStatus: UInt {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
}

private final class ClassATTrackingManager {
    private let classATTrackingManager: NSObjectClass
    private let methodTrackingAuthorizationStatus: NSObjectClassMethod
    
    init?() {
        guard
            let classATTrackingManager = (
                NSObjectClass(name: "ATTrackingManager")
            ),
            let methodTrackingAuthorizationStatus = (
                classATTrackingManager.method(name: "trackingAuthorizationStatus:")
            )
        else {
            return nil
        }
        
        self.classATTrackingManager = classATTrackingManager
        self.methodTrackingAuthorizationStatus = methodTrackingAuthorizationStatus
    }
    
    func trackingAuthorizationStatus() throws -> TrackingAuthorizationStatus {
        let result = classATTrackingManager.call(methodTrackingAuthorizationStatus)
        guard
            let result = result as? UInt,
            let result = TrackingAuthorizationStatus(rawValue: result)
        else {
            throw InternalError.trackingAuthorizationStatusIsNotType
        }
        
        return result
    }
}

extension ClassATTrackingManager {
    enum InternalError: Error {
        case trackingAuthorizationStatusIsNotType
    }
}

#endif
