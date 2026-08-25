import Foundation
import Testing
@testable import SabyConcurrency

extension PromiseTest {
    static func make<Value: Sendable>(_ block: @escaping @Sendable () throws -> Value) -> Promise<Value, Error> {
        Promise<Value, Error> { resolve, _ in resolve(try block()) }
    }

    static func make<Value: Sendable>(_ block: @escaping @Sendable () -> Value) -> Promise<Value, Never> {
        Promise<Value, Never> { resolve, _ in resolve(block()) }
    }

    static func canceled<Value: Sendable, Failure: Error & Sendable>() -> Promise<Value, Failure> {
        let pending = Promise<Value, Failure>.pending()
        pending.cancel()
        return pending.promise
    }

    enum SampleError: Error { case one, two, three }
    enum State<Value> {
        case pending
        case resolved(Value)
        case rejected(Error)
        case canceled
    }

    private enum Completion<Value> {
        case resolved(Value)
        case rejected(Error)
        case canceled
    }

    static func expect<Value: Sendable, Failure: Error & Sendable>(
        promise: Promise<Value, Failure>,
        state: State<@Sendable (Value) -> Bool>,
        timeout: DispatchTimeInterval,
        file: StaticString = #fileID,
        line: UInt = #line
    ) async {
        if case .pending = state {
            #expect(promise.capture().isPending)
            return
        }
        guard let completion = await completion(of: promise, timeout: timeout) else {
            Issue.record("Promise timed out", sourceLocation: sourceLocation(file: file, line: line))
            return
        }
        switch (state, completion) {
        case let (.resolved(expect), .resolved(value)): #expect(expect(value))
        case let (.rejected(expect), .rejected(error)): #expect(error.localizedDescription == expect.localizedDescription)
        case (.canceled, .canceled): break
        default: Issue.record("Promise completed in an unexpected state")
        }
    }

    static func expect<Value: Equatable & Sendable, Failure: Error & Sendable>(
        promise: Promise<Value, Failure>,
        state: State<Value>,
        timeout: DispatchTimeInterval,
        file: StaticString = #fileID,
        line: UInt = #line
    ) async {
        if case .pending = state {
            #expect(promise.capture().isPending)
            return
        }
        guard let completion = await completion(of: promise, timeout: timeout) else {
            Issue.record("Promise timed out", sourceLocation: sourceLocation(file: file, line: line))
            return
        }
        switch (state, completion) {
        case let (.resolved(expect), .resolved(value)): #expect(value == expect)
        case let (.rejected(expect), .rejected(error)): #expect(error.localizedDescription == expect.localizedDescription)
        case (.canceled, .canceled): break
        default: Issue.record("Promise completed in an unexpected state")
        }
    }

    private static func completion<Value: Sendable, Failure: Error & Sendable>(
        of promise: Promise<Value, Failure>,
        timeout: DispatchTimeInterval
    ) async -> Completion<Value>? {
        let result = LockedBox<Completion<Value>?>(nil)
        let completed = AsyncLatch()
        promise.subscribe(
            on: promise.queue,
            onResolved: { value in result.withValue { $0 = .resolved(value) }; completed.signal() },
            onRejected: { error in result.withValue { $0 = .rejected(error) }; completed.signal() },
            onCanceled: { result.withValue { $0 = .canceled }; completed.signal() }
        )
        return await completed.wait(timeout: timeout) ? result.value : nil
    }

    private static func sourceLocation(file: StaticString, line: UInt) -> SourceLocation {
        SourceLocation(fileID: String(describing: file), filePath: String(describing: file), line: Int(line), column: 1)
    }
}
