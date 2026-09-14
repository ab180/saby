//
//  ContractStream.swift
//  SabyConcurrency
//
//  Created by mjgu on 2026/09/14.
//

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Contract where Value: Sendable {
    /// Emits resolve/reject events in order. Rejection is non-terminal; cancel finishes.
    public var stream: AsyncStream<Result<Value, Failure>> {
        AsyncStream { continuation in
            subscribe(
                onResolved: { continuation.yield(.success($0)) },
                onRejected: { continuation.yield(.failure($0)) },
                onCanceled: { continuation.finish() }
            )
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Contract where Value: Sendable, Failure == Never {
    public var stream: AsyncStream<Value> {
        AsyncStream { continuation in
            subscribe(
                onResolved: { continuation.yield($0) },
                onRejected: { _ in },
                onCanceled: { continuation.finish() }
            )
        }
    }
}
