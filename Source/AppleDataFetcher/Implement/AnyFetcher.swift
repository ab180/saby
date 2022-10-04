//
//  Fetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/09/02.
//

import Foundation

extension Fetcher {
    public typealias AnyFetcher = SabyAppleDataFetcher.AnyFetcher<Self.Value>
}

extension Fetcher {
    @inline(__always) @inlinable
    public func toAnyFetcher() -> AnyFetcher {
        AnyFetcher(self)
    }
}

public struct AnyFetcher<Value>: Fetcher {
    @usableFromInline
    let fetcherBox: AnyFetcherBoxBase<Value>
    
    @inline(__always) @inlinable
    public init<ActualFetcher: Fetcher>(_ fetcher: ActualFetcher) where
        ActualFetcher.Value == Value
    {
        if let anyFetcher = fetcher as? AnyFetcher<Value> {
            self.fetcherBox = anyFetcher.fetcherBox
        }
        else {
            self.fetcherBox = AnyFetcherBox(fetcher)
        }
    }
    
    @inline(__always) @inlinable
    public func fetch() -> Value {
        fetcherBox.fetch()
    }
}

@usableFromInline
class AnyFetcherBoxBase<Value>: Fetcher {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func fetch() -> Value { fatalError() }
}

@usableFromInline
final class AnyFetcherBox<ActualFetcher: Fetcher>: AnyFetcherBoxBase<
    ActualFetcher.Value
> {
    @usableFromInline
    let fetcher: ActualFetcher
    
    @inline(__always) @inlinable
    init(_ fetcher: ActualFetcher) {
        self.fetcher = fetcher
    }

    @inline(__always) @inlinable
    override func fetch() -> Value {
        fetcher.fetch()
    }
}
