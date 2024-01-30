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
        Promise.async {
            try self.classAAAttribution.attributionToken()
        }
    }
}

public typealias AppleAdsAttributionToken = String

private final class ClassAAAttribution {
    private let classAAAttribution: NSObjectClass
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
        
        self.classAAAttribution = classAAAttribution
        self.methodAttributionTokenWithError = methodAttributionTokenWithError
    }
    
    func attributionToken() throws -> String {
        let error = UnsafeMutablePointer<NSError?>.allocate(capacity: 1)
        defer { error.deallocate() }
        
        let result = classAAAttribution.call(
            methodAttributionTokenWithError,
            with: OpaquePointer(error),
            return: .reference
        )
        if let error = error.pointee {
            throw error
        }
        guard let result = result as? String else {
            throw AppleAdsAttributionTokenFetcherError.attributionTokenIsNotString
        }
        
        return result
    }
}

public enum AppleAdsAttributionTokenFetcherError: Error {
    case attributionTokenIsNotString
}

#endif
