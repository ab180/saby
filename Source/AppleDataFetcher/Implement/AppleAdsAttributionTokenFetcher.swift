//
//  AppleAdsAttributionTokenFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/22.
//

#if os(iOS) || os(macOS)

import Foundation

import SabyAppleObjectiveCReflection
import SabyConcurrency

public final class AppleAdsAttributionTokenFetcher: Fetcher {
    public typealias Value = Promise<String>
    
    private let classAAAttribution: ClassAAAttribution
    
    public init?() {
        guard let classAAAttribution = ClassAAAttribution() else { return nil }
        
        self.classAAAttribution = classAAAttribution
    }
    
    public func fetch() -> Promise<String> {
        Promise {
            try self.classAAAttribution.attributionToken()
        }
    }
}

private final class ClassAAAttribution {
    private let classAAAttribution: NSObject.Class
    private let methodAttributionTokenWithError: NSObject.ClassMethod
    
    init?() {
        guard
            let classAAAttribution
                = NSObject.Class(name: "AAAttribution"),
            let methodAttributionTokenWithError
                = classAAAttribution.method(name: "attributionTokenWithError:")
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
            with: OpaquePointer(error)
        )
        if let error = error.pointee {
            throw error
        }
        guard let result = result as? String else {
            throw InternalError.attributionTokenIsNotString
        }
        
        return result
    }
}

extension ClassAAAttribution {
    enum InternalError: Error {
        case attributionTokenIsNotString
    }
}

#endif
