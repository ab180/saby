import Foundation
import Testing
@testable import SabyConcurrency

extension ContractTest {
    enum SampleError: Error { case one, two, three }
    enum State<Value> { case resolved(Value), rejected(Error), canceled }
    private enum Completion<Value> { case resolved(Value), rejected(Error), canceled }

    static func expect<Value: Equatable & Sendable, Failure: Error & Sendable>(
        contract: Contract<Value, Failure>,
        state: State<Value>,
        timeout: DispatchTimeInterval,
        block: () -> Void,
        file: StaticString = #fileID,
        line: UInt = #line
    ) async {
        let result = LockedBox<Completion<Value>?>(nil)
        let completed = AsyncLatch()
        let record: @Sendable (Completion<Value>) -> Void = { completion in
            let isFirst = result.withValue { current in
                guard current == nil else { return false }
                current = completion
                return true
            }
            if isFirst { completed.signal() }
        }
        contract.subscribe(
            on: contract.queue,
            onResolved: { record(.resolved($0)) },
            onRejected: { record(.rejected($0)) },
            onCanceled: { record(.canceled) }
        )
        block()
        guard await completed.wait(timeout: timeout), let completion = result.value else {
            Issue.record("Contract timed out", sourceLocation: sourceLocation(file: file, line: line))
            return
        }
        switch (state, completion) {
        case let (.resolved(expect), .resolved(value)): #expect(value == expect)
        case let (.rejected(expect), .rejected(error)): #expect(error.localizedDescription == expect.localizedDescription)
        case (.canceled, .canceled): break
        default: Issue.record("Contract completed in an unexpected state")
        }
    }

    private static func sourceLocation(file: StaticString, line: UInt) -> SourceLocation {
        SourceLocation(fileID: String(describing: file), filePath: String(describing: file), line: Int(line), column: 1)
    }
}
