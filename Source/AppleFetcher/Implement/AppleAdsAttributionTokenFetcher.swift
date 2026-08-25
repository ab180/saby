//
//  AppleAdsAttributionTokenFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/22.
//

#if os(iOS) || os(macOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class AppleAdsAttributionTokenFetcher: Fetcher {
    public typealias Value = Promise<AppleAdsAttributionToken, Error>
    
    private let classAAAttribution: ClassAAAttribution
    
    public init?() {
        guard let classAAAttribution = ClassAAAttribution() else { return nil }
        
        self.classAAAttribution = classAAAttribution
    }
    
    public func fetch() -> Promise<AppleAdsAttributionToken, Error> {
        let classAAAttribution = self.classAAAttribution

        return Promise.async {
            try await classAAAttribution.attributionToken()
        }
    }
}

public typealias AppleAdsAttributionToken = String

private actor ClassAAAttribution {
    private let methodAttributionTokenWithError: NSObjectClassMethod
    
    init?() {
        guard
            let classAAAttribution = (
                NSObjectClass(name: "AAAttribution")
            ),
            let methodAttributionTokenWithError = (
                classAAAttribution.method(name: "attributionTokenWithError:")
            )
        else {
            return nil
        }
        
        self.methodAttributionTokenWithError = methodAttributionTokenWithError
    }
    
    func attributionToken() throws -> String {
        let error = UnsafeMutablePointer<NSError?>.allocate(capacity: 1)
        error.initialize(to: nil)
        
        let result = {
            let function = unsafeBitCast(
                methodAttributionTokenWithError.implementation,
                to: (@convention(c)(AnyClass, Selector, OpaquePointer)->String).self
            )
            return function(
                methodAttributionTokenWithError.anyClass,
                methodAttributionTokenWithError.selector,
                OpaquePointer(error)
            )
        }()
        
        if let error = error.pointee {
            throw error
        }
        
        error.deinitialize(count: 1)
        error.deallocate()
        
        return result
    }
}

#endif
