//
//  JSONClient.swift
//  SabyRequest
//
//  Created by WOF on 2022/08/16.
//

import Foundation

import SabyConcurrency
import SabyJSON
import SabyTime

public final class JSONClient: Client, Sendable {
    let client: DataClient
    let tasks: PromiseTaskScope
    
    init(
        client: DataClient,
        cancelWhen: PromisePendingCancelWhen
    ) {
        self.client = client
        self.tasks = PromiseTaskScope(cancelWhen: cancelWhen)
    }
}

extension JSONClient {
    public convenience init(
        cancelWhen: PromisePendingCancelWhen,
        optionBlock: @Sendable (inout URLSessionConfiguration) -> Void = { _ in }
    ) {
        let client = DataClient(cancelWhen: cancelWhen, optionBlock: optionBlock)
        self.init(client: client, cancelWhen: cancelWhen)
    }
}
    
extension JSONClient {
    public func request(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: JSON? = nil,
        timeout: Interval? = nil,
        optionBlock: @escaping @Sendable (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<JSON>, Error> {
        let header = header.merging([
            "Content-Type": "application/json"
        ]) { _, new in new }
        
        var bodyData: Data? = nil
        if let body {
            guard let body = try? body.datafy() else {
                return Promise.rejected(JSONClientError.bodyIsNotEncodable)
            }
            bodyData = body
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        header.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpBody = bodyData
        optionBlock(&request)

        let requestSnapshot = request
        let session = client.session

        return tasks.promise {
            do {
                let (code, headers, data) = try await session.result(
                    for: requestSnapshot,
                    timeout: timeout
                )
                guard let data, let body = try? JSON.parse(data) else {
                    throw JSONClientError.responseDataIsNotDecodable(code: code, body: data)
                }

                return (code, headers, body)
            } catch DataClientError.timeout {
                throw JSONClientError.timeout
            } catch DataClientError.statusCodeNotFound {
                throw JSONClientError.statusCodeNotFound
            } catch DataClientError.statusCodeNot2XX(let code, let data) {
                guard let data, let body = try? JSON.parse(data) else {
                    throw JSONClientError.responseDataIsNotDecodable(code: code, body: data)
                }
                throw JSONClientError.statusCodeNot2XX(codeNot2XX: code, body: body)
            }
        }
    }
}

public enum JSONClientError: Error {
    case timeout
    case statusCodeNotFound
    case statusCodeNot2XX(codeNot2XX: Int, body: JSON)
    case bodyIsNotEncodable
    case responseDataIsNotDecodable(code: Int, body: Data?)
}
