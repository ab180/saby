//
//  DataClient.swift
//  SabyRequest
//
//  Created by WOF on 2022/08/09.
//

import Foundation

import SabyConcurrency
import SabyJSON
import SabyTime

public final class DataClient: Client, Sendable {
    public typealias Request = Data?
    public typealias Response = Data?

    let tasks: PromiseTaskScope
    
    let session: URLSession
    
    init(
        session: URLSession,
        cancelWhen: PromisePendingCancelWhen
    ) {
        self.session = session
        self.tasks = PromiseTaskScope(cancelWhen: cancelWhen)
    }
}

extension DataClient {
    public convenience init(
        cancelWhen: PromisePendingCancelWhen,
        optionBlock: @Sendable (inout URLSessionConfiguration) -> Void = { _ in }
    ) {
        var configuration = URLSessionConfiguration.default
        optionBlock(&configuration)
    
        let session = URLSession(configuration: configuration)
        self.init(
            session: session,
            cancelWhen: cancelWhen
        )
    }
}

extension DataClient {
    public func request(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: Data? = nil,
        timeout: Interval? = nil,
        optionBlock: @escaping @Sendable (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<Data?>, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        header.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        optionBlock(&request)

        let requestSnapshot = request
        let session = self.session

        return tasks.promise {
            try await session.result(
                for: requestSnapshot,
                timeout: timeout
            )
        }
    }
}

struct DataClientResponse: Sendable {
    let code: Int
    let headers: ClientHeader
    let body: Data

    var result: ClientResult<Data?> { (code, headers, body) }
}

extension URLSession {
    func result(
        for request: URLRequest,
        timeout: Interval?
    ) async throws -> ClientResult<Data?> {
        guard let timeout else {
            return try await response(for: request).result
        }

        return try await withThrowingTaskGroup(of: DataClientResponse.self) { group in
            group.addTask { try await self.response(for: request) }
            group.addTask {
                try await Task.sleep(nanoseconds: timeout.nanoseconds)
                throw DataClientError.timeout
            }

            defer { group.cancelAll() }
            guard let response = try await group.next() else {
                throw CancellationError()
            }
            return response.result
        }
    }

    func response(for request: URLRequest) async throws -> DataClientResponse {
        let (data, response) = try await data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw DataClientError.statusCodeNotFound
        }

        let code = response.statusCode
        guard code / 100 == 2 else {
            throw DataClientError.statusCodeNot2XX(codeNot2XX: code, body: data)
        }

        return DataClientResponse(
            code: code,
            headers: response.headers,
            body: data
        )
    }
}

extension Interval {
    var nanoseconds: UInt64 {
        UInt64(max(0, second * 1_000_000_000))
    }
}

public enum DataClientError: Error {
    case timeout
    case statusCodeNotFound
    case statusCodeNot2XX(codeNot2XX: Int, body: Data?)
}

private extension HTTPURLResponse {
    var headers: ClientHeader {
        allHeaderFields.reduce(into: [:]) { headers, field in
            guard let key = field.key as? String else { return }
            headers[key] = String(describing: field.value)
        }
    }
}
