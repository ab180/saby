//
//  IdentifierForAdvertiserFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class IdentifierForAdvertiserFetcher: Fetcher {
    public typealias Value = Promise<IdentifierForAdvertiser>
    
    private let instanceASIdentifierManager: InstanceASIdentifierManager
    
    public init?() {
        guard
            let classASIdentifierManager = ClassASIdentifierManager(),
            let instanceASIdentifierManager = classASIdentifierManager.shared()
        else {
            return nil
        }
        
        self.instanceASIdentifierManager = instanceASIdentifierManager
    }
    
    public func fetch() -> Promise<IdentifierForAdvertiser> {
        Promise {
            IdentifierForAdvertiser(
                identifier: try self.instanceASIdentifierManager.advertisingIdentifier(),
                limitAdTracking: try self.instanceASIdentifierManager.advertisingTrackingEnabled()
            )
        }
    }
}

public struct IdentifierForAdvertiser {
    public let identifier: String
    public let limitAdTracking: Bool
}

private final class ClassASIdentifierManager {
    private let classASIdentifierManager: NSObjectClass
    private let methodSharedManager: NSObjectClassMethod
    
    init?() {
        guard
            let ASIdentifierManager = NSObjectClass(name: "ASIdentifierManager"),
            let sharedManager = ASIdentifierManager.method(name: "sharedManager")
        else {
            return nil
        }
        
        self.classASIdentifierManager = ASIdentifierManager
        self.methodSharedManager = sharedManager
    }
    
    func shared() -> InstanceASIdentifierManager? {
        let result = classASIdentifierManager.call(methodSharedManager)
        guard let result = InstanceASIdentifierManager(object: result) else {
            return nil
        }
        
        return result
    }
}

private final class InstanceASIdentifierManager {
    private let instanceASIdentifierManager: NSObjectInstance
    private let methodAdvertisingIdentifier: NSObjectInstanceMethod
    private let methodAdvertisingTrackingEnabled: NSObjectInstanceMethod
    
    init?(object: Any?) {
        guard
            let classASIdentifierManager = (
                NSObjectClass(name: "ASIdentifierManager")
            ),
            let instanceASIdentifierManager = (
                classASIdentifierManager.instance(object: object)
            ),
            let methodAdvertisingIdentifier = (
                instanceASIdentifierManager.method(name: "advertisingIdentifier")
            ),
            let methodAdvertisingTrackingEnabled = (
                instanceASIdentifierManager.method(name: "advertisingTrackingEnabledMethod")
            )
        else {
            return nil
        }
        
        self.instanceASIdentifierManager = instanceASIdentifierManager
        self.methodAdvertisingIdentifier = methodAdvertisingIdentifier
        self.methodAdvertisingTrackingEnabled = methodAdvertisingTrackingEnabled
    }
    
    func advertisingIdentifier() throws -> String {
        guard
            let result = (
                instanceASIdentifierManager.call(methodAdvertisingIdentifier) as? UUID
            )
        else {
            throw InternalError.advertisingIdentifierIsNotUUID
        }
        
        return result.uuidString
    }
    
    func advertisingTrackingEnabled() throws -> Bool {
        guard
            let enabled = (
                instanceASIdentifierManager.call(methodAdvertisingTrackingEnabled) as? Bool
            )
        else {
            throw InternalError.advertisingTrackingEnabledIsNotBool
        }
        
        return enabled
    }
}

extension InstanceASIdentifierManager {
    enum InternalError: Error {
        case advertisingIdentifierIsNotUUID
        case advertisingTrackingEnabledIsNotBool
    }
}

#endif
