//
//  PromiseTaskScope.swift
//  SabyConcurrency
//
//  Created by mjgu on 2026/09/14.
//

import Foundation

/// Owns asynchronous operations exposed as promises.
/// Use `.deinit` to cancel outstanding operations when the scope is released.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class PromiseTaskScope {
    private let tasks = ConcurrencyTaskBag()
    private let cancelWhen: PromisePendingCancelWhen

    public init(cancelWhen: PromisePendingCancelWhen = .none) {
        self.cancelWhen = cancelWhen
    }

    deinit {
        if case .deinit = cancelWhen { tasks.cancelAll() }
    }

    public func promise<Value: Sendable>(
        _ operation: @escaping @Sendable () async throws -> Value
    ) -> Promise<Value, Error> {
        start {
            do { return .success(try await operation()) }
            catch { return .failure(error) }
        }
    }

    public func promise<Value: Sendable>(
        _ operation: @escaping @Sendable () async -> Value
    ) -> Promise<Value, Never> {
        start { .success(await operation()) }
    }

    var isEmpty: Bool { tasks.isEmpty }

    private func start<Value: Sendable, Failure: Error>(
        _ operation: @escaping @Sendable () async -> Result<Value, Failure>
    ) -> Promise<Value, Failure> {
        let pending = Promise<Value, Failure>.pending()
        let identifier = UUID()
        let tasks = self.tasks
        let task = Task {
            defer { tasks.remove(identifier) }
            guard !Task.isCancelled else {
                pending.cancel()
                return
            }
            let result = await operation()
            if Task.isCancelled {
                pending.cancel()
            } else {
                switch result {
                case .success(let value): pending.resolve(value)
                case .failure(let error): pending.reject(error)
                }
            }
        }
        tasks.insert(identifier, task: task)
        pending.onCancel { task.cancel() }
        return pending.promise
    }
}
