//
//  AppleSearchAdsAttributionFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/22.
//

#if os(iOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class AppleSearchAdsAttributionFetcher: Fetcher {
    typealias Value = Promise<[String: NSObject]>
    
    private let instanceADClient: InstanceADClient
    
    public init?() {
        guard
            let classADClient = ClassADClient(),
            let instanceADClient = classADClient.shared()
        else {
            return nil
        }
        
        self.instanceADClient = instanceADClient
    }
    
    public func fetch() -> Promise<[String: NSObject]> {
        Promise { resolve, reject in
            self.instanceADClient.requestAttributionDetailsWithBlock { attribution, error in
                if let attribution = attribution {
                    resolve(attribution)
                    return
                }
                else if let error = error {
                    reject(error)
                    return
                }
                else {
                    reject(InternalError.attributionAndErrorAreBothNil)
                }
            }
        }
    }
}

extension AppleSearchAdsAttributionFetcher {
    enum InternalError: Error {
        case attributionAndErrorAreBothNil
    }
}

private final class ClassADClient {
    private let ADClientClass: NSObject.Class
    private let sharedClientMethod: NSObject.ClassMethod
    
    init?() {
        guard
            let ADClientClass = NSObject.Class(name: "ADClient"),
            let sharedClientMethod = ADClientClass.method(name: "sharedClient")
        else {
            return nil
        }
        
        self.ADClientClass = ADClientClass
        self.sharedClientMethod = sharedClientMethod
    }
    
    func shared() -> InstanceADClient? {
        let result = ADClientClass.call(sharedClientMethod)
        guard let result = InstanceADClient(object: result) else {
            return nil
        }
        
        return result
    }
}

private final class InstanceADClient {
    private let instance: NSObject.Instance
    private let requestAttributionDetailsWithBlockMethod: NSObject.InstanceMethod
    
    init?(object: Any?) {
        guard
            let ADClientClass = NSObject.Class(name: "ADClient"),
            let instance = ADClientClass.instance(object: object),
            let requestAttributionDetailsWithBlockMethod = instance.method(name: "requestAttributionDetailsWithBlock:")
        else {
            return nil
        }
        
        self.instance = instance
        self.requestAttributionDetailsWithBlockMethod = requestAttributionDetailsWithBlockMethod
    }
    
    func requestAttributionDetailsWithBlock(
        handler: @escaping ([String: NSObject]?, Error?) -> Void
    ) {
        let handler: @convention(block) ([String: NSObject]?, Error?) -> Void = handler
        
        instance.call(requestAttributionDetailsWithBlockMethod, with: handler)
    }
}

#endif
