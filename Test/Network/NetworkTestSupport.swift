import Foundation
import Testing

import SabyConcurrency

enum NetworkTestError: Error {
    case sample
    case timeout
}

func expectResolved<Value: Sendable, Failure: Error & Sendable>(
    _ promise: Promise<Value, Failure>,
    timeoutNanoseconds: UInt64 = 2_000_000_000,
    where predicate: (Value) -> Bool,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        let value = try await promiseValue(promise, timeoutNanoseconds: timeoutNanoseconds)
        #expect(predicate(value), sourceLocation: sourceLocation(file: file, line: line))
    } catch {
        Issue.record("Expected resolved promise, received \(error)", sourceLocation: sourceLocation(file: file, line: line))
    }
}

func expectRejected<Value: Sendable, Failure: Error & Sendable>(
    _ promise: Promise<Value, Failure>,
    error expected: Error,
    timeoutNanoseconds: UInt64 = 2_000_000_000,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await promiseValue(promise, timeoutNanoseconds: timeoutNanoseconds)
        Issue.record("Expected rejected promise", sourceLocation: sourceLocation(file: file, line: line))
    } catch {
        #expect(error.localizedDescription == expected.localizedDescription, sourceLocation: sourceLocation(file: file, line: line))
    }
}

func expectCanceled<Value: Sendable, Failure: Error & Sendable>(
    _ promise: Promise<Value, Failure>,
    timeoutNanoseconds: UInt64 = 2_000_000_000,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await promiseValue(promise, timeoutNanoseconds: timeoutNanoseconds)
        Issue.record("Expected canceled promise", sourceLocation: sourceLocation(file: file, line: line))
    } catch is CancellationError {
        return
    } catch {
        Issue.record("Expected cancellation, received \(error)", sourceLocation: sourceLocation(file: file, line: line))
    }
}

private func promiseValue<Value: Sendable, Failure: Error & Sendable>(
    _ promise: Promise<Value, Failure>,
    timeoutNanoseconds: UInt64
) async throws -> Value {
    try await withThrowingTaskGroup(of: Value.self) { group in
        group.addTask { try await promise.value() }
        group.addTask {
            try await Task.sleep(nanoseconds: timeoutNanoseconds)
            throw NetworkTestError.timeout
        }
        defer { group.cancelAll() }
        return try await group.next()!
    }
}

private func sourceLocation(file: StaticString, line: UInt) -> SourceLocation {
    let path = String(describing: file)
    return SourceLocation(
        fileID: path,
        filePath: path,
        line: Int(line),
        column: 1
    )
}

func eventually(
    timeoutNanoseconds: UInt64 = 2_000_000_000,
    condition: () -> Bool
) async -> Bool {
    let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

    while !condition() {
        guard DispatchTime.now().uptimeNanoseconds < deadline else { return false }
        try? await Task.sleep(nanoseconds: 10_000_000)
    }

    return true
}

protocol URLResultStorage: SendableMetatype {
    static var results: [URLResult] { get }
}

final class MockURLProtocol<Storage: URLResultStorage>: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool {
        request.url.map { url in Storage.results.contains { $0.url == url } } ?? false
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard
            let url = request.url,
            let result = Storage.results.first(where: { $0.url == url })
        else {
            client?.urlProtocol(self, didFailWithError: NetworkTestError.sample)
            return
        }

        if let response = result.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let error = result.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        result.data
            .then { [weak self] data in
                guard let self, let data else { return }
                client?.urlProtocol(self, didLoad: data)
            }
            .then { [weak self] in
                guard let self else { return }
                client?.urlProtocolDidFinishLoading(self)
            }
    }

    override func stopLoading() {}
}

struct URLResult {
    let url: URL
    let response: URLResponse?
    let data: Promise<Data?, Never>
    let error: Error?

    init(url: URL, code: Int, headers: [String: String] = [:], data: Data?) {
        self.init(url: url, code: code, headers: headers, data: .resolved(data))
    }

    init(url: URL, code: Int, headers: [String: String] = [:], data: Promise<Data?, Never>) {
        self.url = url
        self.response = HTTPURLResponse(
            url: url,
            statusCode: code,
            httpVersion: nil,
            headerFields: headers
        )
        self.data = data
        self.error = nil
    }

    init(url: URL, error: Error) {
        self.url = url
        self.response = nil
        self.data = .resolved(nil)
        self.error = error
    }
}
