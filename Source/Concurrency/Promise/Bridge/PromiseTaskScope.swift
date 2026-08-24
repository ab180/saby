//
//  PromiseTaskScope.swift
//  SabyConcurrency
//

import Foundation

public final class PromiseTaskScope: Sendable {
    private let storage: Storage

    public init(cancelWhen: PromisePendingCancelWhen = .none) {
        self.storage = Storage(cancelWhen: cancelWhen)
    }

    public func promise<
        Value: Sendable,
        Failure: Error & Sendable
    >(
        _ operation: @escaping @Sendable () async throws(Failure) -> Value
    ) -> Promise<Value, Failure> {
        let pending = Promise<Value, Failure>.pending()
        let identifier = UUID()
        let storage = self.storage
        let registration = Task {
            await storage.start(identifier: identifier) {
                let result = await capture(operation)

                if Task.isCancelled {
                    pending.cancel()
                } else {
                    switch result {
                    case .success(let value): pending.resolve(value)
                    case .failure(let error): pending.reject(error)
                    }
                }
            }
        }

        pending.onCancel { [weak storage] in
            Task {
                await registration.value
                await storage?.cancel(identifier: identifier)
            }
        }

        return pending.promise
    }

    var isEmpty: Bool {
        get async { await storage.isEmpty }
    }
}

private func capture<
    Value: Sendable,
    Failure: Error & Sendable
>(
    _ operation: @escaping @Sendable () async throws(Failure) -> Value
) async -> Result<Value, Failure> {
    do {
        return .success(try await operation())
    } catch {
        return .failure(error)
    }
}

private extension PromiseTaskScope {
    actor Storage {
        typealias RequestTask = Task<Void, Never>

        private let cancelWhen: PromisePendingCancelWhen
        private var tasks: [UUID: RequestTask] = [:]

        init(cancelWhen: PromisePendingCancelWhen) {
            self.cancelWhen = cancelWhen
        }

        deinit {
            guard case .deinit = cancelWhen else { return }
            tasks.values.forEach { $0.cancel() }
        }

        var isEmpty: Bool { tasks.isEmpty }

        func start(
            identifier: UUID,
            operation: @escaping @Sendable () async -> Void
        ) {
            tasks[identifier] = Task { [weak self] in
                await operation()
                await self?.remove(identifier: identifier)
            }
        }

        func cancel(identifier: UUID) {
            tasks.removeValue(forKey: identifier)?.cancel()
        }

        private func remove(identifier: UUID) {
            tasks[identifier] = nil
        }
    }
}
