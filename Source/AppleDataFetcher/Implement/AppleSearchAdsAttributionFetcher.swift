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
    public typealias Value = Promise<[String: NSObject]>
    
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
    private let classADClient: NSObject.Class
    private let methodSharedClient: NSObject.ClassMethod
    
    init?() {
        guard
            let classADClient = NSObject.Class(name: "ADClient"),
            let methodSharedClient = classADClient.method(name: "sharedClient")
        else {
            return nil
        }
        
        self.classADClient = classADClient
        self.methodSharedClient = methodSharedClient
    }
    
    func shared() -> InstanceADClient? {
        let result = classADClient.call(methodSharedClient)
        guard let result = InstanceADClient(object: result) else {
            return nil
        }
        
        return result
    }
}

private final class InstanceADClient {
    private let instanceADClient: NSObject.Instance
    private let methodRequestAttributionDetailsWithBlock: NSObject.InstanceMethod
    
    init?(object: Any?) {
        guard
            let classADClient
                = NSObject.Class(name: "ADClient"),
            let instanceADClient
                = classADClient.instance(object: object),
            let methodRequestAttributionDetailsWithBlock
                = instanceASIdentifierManager.method(name: "requestAttributionDetailsWithBlock:")
        else {
            return nil
        }
        
        self.instanceADClient = instanceADClient
        self.methodRequestAttributionDetailsWithBlock = methodRequestAttributionDetailsWithBlock
    }
    
    func requestAttributionDetailsWithBlock(
        handler: @escaping ([String: NSObject]?, Error?) -> Void
    ) {
        let handler: @convention(block) (
            [String: NSObject]?,
            Error?
        ) -> Void = handler
        
        instanceADClient.call(
            methodRequestAttributionDetailsWithBlock,
            with: handler
        )
    }
}

#endif
