import Foundation

final class LockedBox<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: Value

    init(_ value: Value) {
        storage = value
    }

    var value: Value {
        lock.withLock { storage }
    }

    @discardableResult
    func withValue<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        try lock.withLock { try body(&storage) }
    }
}

final class AsyncLatch: Sendable {
    private let core = Core()

    func signal() {
        Task { await core.signal() }
    }

    func wait(
        count: Int = 1,
        timeout: DispatchTimeInterval
    ) async -> Bool {
        let identifier = UUID()

        return await withTaskCancellationHandler {
            await core.wait(
                identifier: identifier,
                count: count,
                timeoutNanoseconds: timeout.nanoseconds
            )
        } onCancel: {
            Task { await core.cancel(identifier: identifier) }
        }
    }

    private actor Core {
        private var signals = 0
        private var canceledIdentifiers: Set<UUID> = []
        private var waiters: [Waiter] = []

        func signal() {
            signals += 1
            resumeWaiters()
        }

        func wait(
            identifier: UUID,
            count: Int,
            timeoutNanoseconds: UInt64
        ) async -> Bool {
            guard canceledIdentifiers.remove(identifier) == nil else { return false }
            guard signals < count else {
                signals -= count
                return true
            }

            return await withCheckedContinuation { continuation in
                let timeoutTask: Task<Void, Never>? = if timeoutNanoseconds == .max {
                    nil
                } else {
                    Task { [weak self] in
                        try? await Task.sleep(nanoseconds: timeoutNanoseconds)
                        await self?.timeout(identifier: identifier)
                    }
                }
                waiters.append(
                    Waiter(
                        identifier: identifier,
                        count: count,
                        continuation: continuation,
                        timeoutTask: timeoutTask
                    )
                )
            }
        }

        func cancel(identifier: UUID) {
            guard let index = waiters.firstIndex(where: { $0.identifier == identifier }) else {
                canceledIdentifiers.insert(identifier)
                return
            }

            let waiter = waiters.remove(at: index)
            waiter.timeoutTask?.cancel()
            waiter.continuation.resume(returning: false)
        }

        private func timeout(identifier: UUID) {
            guard let index = waiters.firstIndex(where: { $0.identifier == identifier }) else {
                return
            }

            waiters.remove(at: index).continuation.resume(returning: false)
        }

        private func resumeWaiters() {
            while let waiter = waiters.first, signals >= waiter.count {
                signals -= waiter.count
                waiters.removeFirst()
                waiter.timeoutTask?.cancel()
                waiter.continuation.resume(returning: true)
            }
        }

        private struct Waiter {
            let identifier: UUID
            let count: Int
            let continuation: CheckedContinuation<Bool, Never>
            let timeoutTask: Task<Void, Never>?
        }
    }
}

private extension DispatchTimeInterval {
    var nanoseconds: UInt64 {
        switch self {
        case .seconds(let value): UInt64(max(0, value)) * 1_000_000_000
        case .milliseconds(let value): UInt64(max(0, value)) * 1_000_000
        case .microseconds(let value): UInt64(max(0, value)) * 1_000
        case .nanoseconds(let value): UInt64(max(0, value))
        case .never: .max
        @unknown default: .max
        }
    }
}
