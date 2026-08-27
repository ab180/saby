//
//  ContractStream.swift
//  SabyConcurrency
//
//  Created by WOF on 2026/08/27.
//

extension Contract {
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
