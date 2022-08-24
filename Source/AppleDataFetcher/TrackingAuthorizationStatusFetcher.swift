//
//  TrackingAuthorizationStatusFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class TrackingAuthorizationStatusFetcher: Fetcher {
    typealias Value = Promise<TrackingAuthorizationStatus>
    
    private let classATTrackingManager: ClassATTrackingManager
    
    init?() {
        guard let classATTrackingManager = ClassATTrackingManager() else { return nil }
        
        self.classATTrackingManager = classATTrackingManager
    }
    
    func fetch() -> Promise<TrackingAuthorizationStatus> {
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
    private let ATTrackingManagerClass: NSObject.Class
    private let trackingAuthorizationStatusMethod: NSObject.ClassMethod
    
    init?() {
        guard
            let ATTrackingManagerClass = NSObject.Class(name: "ATTrackingManager"),
            let trackingAuthorizationStatusMethod = ATTrackingManagerClass.method(name: "trackingAuthorizationStatus:")
        else {
            return nil
        }
        
        self.ATTrackingManagerClass = ATTrackingManagerClass
        self.trackingAuthorizationStatusMethod = trackingAuthorizationStatusMethod
    }
    
    func trackingAuthorizationStatus() throws -> TrackingAuthorizationStatus {
        let result = ATTrackingManagerClass.call(trackingAuthorizationStatusMethod)
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
