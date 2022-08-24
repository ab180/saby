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
    typealias Value = Promise<IdentifierForAdvertiser>
    
    private let instanceASIdentifierManager: InstanceASIdentifierManager
    
    init?() {
        guard
            let classASIdentifierManager = ClassASIdentifierManager(),
            let instanceASIdentifierManager = classASIdentifierManager.shared()
        else {
            return nil
        }
        
        self.instanceASIdentifierManager = instanceASIdentifierManager
    }
    
    func fetch() -> Promise<IdentifierForAdvertiser> {
        Promise {
            IdentifierForAdvertiser(
                identifier: try self.instanceASIdentifierManager.advertisingIdentifier(),
                limitAdTracking: try self.instanceASIdentifierManager.advertisingTrackingEnabled()
            )
        }
    }
}

public struct IdentifierForAdvertiser {
    let identifier: String
    let limitAdTracking: Bool
}

private final class ClassASIdentifierManager {
    private let ASIdentifierManagerClass: NSObject.Class
    private let sharedManagerMethod: NSObject.ClassMethod
    
    init?() {
        guard
            let ASIdentifierManager = NSObject.Class(name: "ASIdentifierManager"),
            let sharedManager = ASIdentifierManager.method(name: "sharedManager")
        else {
            return nil
        }
        
        self.ASIdentifierManagerClass = ASIdentifierManager
        self.sharedManagerMethod = sharedManager
    }
    
    func shared() -> InstanceASIdentifierManager? {
        let result = ASIdentifierManagerClass.call(sharedManagerMethod)
        guard let result = InstanceASIdentifierManager(object: result) else {
            return nil
        }
        
        return result
    }
}

private final class InstanceASIdentifierManager {
    private let instance: NSObject.Instance
    private let advertisingIdentifierMethod: NSObject.InstanceMethod
    private let advertisingTrackingEnabledMethod: NSObject.InstanceMethod
    
    init?(object: Any?) {
        guard
            let ADClient = NSObject.Class(name: "ADClient"),
            let instance = ADClient.instance(object: object),
            let advertisingIdentifier = instance.method(name: "advertisingIdentifier"),
            let advertisingTrackingEnabledMethod = instance.method(name: "advertisingTrackingEnabledMethod")
        else {
            return nil
        }
        
        self.instance = instance
        self.advertisingIdentifierMethod = advertisingIdentifier
        self.advertisingTrackingEnabledMethod = advertisingTrackingEnabledMethod
    }
    
    func advertisingIdentifier() throws -> String {
        guard let result = instance.call(advertisingIdentifierMethod) as? UUID else {
            throw InternalError.advertisingIdentifierIsNotUUID
        }
        
        return result.uuidString
    }
    
    func advertisingTrackingEnabled() throws -> Bool {
        guard let enabled = instance.call(advertisingTrackingEnabledMethod) as? Bool else {
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
