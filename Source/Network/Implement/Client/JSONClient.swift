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

public final class JSONClient: Client {
    let client: DataClient
    
    init(
        client: DataClient
    ) {
        self.client = client
    }
}

extension JSONClient {
    public convenience init(
        cancelWhen: PromisePendingCancelWhen,
        optionBlock: (inout URLSessionConfiguration) -> Void = { _ in }
    ) {
        let client = DataClient(cancelWhen: cancelWhen, optionBlock: optionBlock)
        self.init(client: client)
    }
}
    
extension JSONClient {
    public func request(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: JSON? = nil,
        timeout: Interval? = nil,
        optionBlock: @escaping (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<JSON>, Error> {
        let header = header.merging([
            "Content-Type": "application/json"
        ]) { _, new in new }
        
        var bodyData: Data? = nil
        if let body {
            guard let body = try? body.datafy() else {
                return Promise.rejected(JSONClientError.bodyIsNotEncodable(headers: nil))
            }
            bodyData = body
        }
        
        return client.request(
            url: url,
            method: method,
            header: header,
            body: bodyData,
            timeout: timeout,
            optionBlock: optionBlock
        )
        .then { code2XX, headers, data -> ClientResult<JSON> in
            guard let data, let body = try? JSON.parse(data) else {
                throw JSONClientError.responseDataIsNotDecodable(
                    code: code2XX,
                    headers: headers,
                    body: data
                )
            }
            
            
            return (code2XX, headers, body)
        }
        .catch { error in
            if case DataClientError.requestFailed(let error, let headers) = error {
                throw JSONClientError.requestFailed(error: error, headers: headers)
            }
            else if case DataClientError.timeout(let headers) = error {
                throw JSONClientError.timeout(headers: headers)
            }
            else if case DataClientError.statusCodeNotFound(let headers) = error {
                throw JSONClientError.statusCodeNotFound(headers: headers)
            }
            else if case DataClientError.statusCodeNot2XX(
                let codeNot2XX,
                let headers,
                let data
            ) = error {
                throw JSONClientError.statusCodeNot2XX(
                    codeNot2XX: codeNot2XX,
                    headers: headers,
                    body: data.flatMap { try? JSON.parse($0) }
                )
            }
        }
    }
}

public enum JSONClientError: ClientError {
    case requestFailed(error: Error, headers: ClientHeader?)
    case timeout(headers: ClientHeader?)
    case statusCodeNotFound(headers: ClientHeader?)
    case statusCodeNot2XX(codeNot2XX: Int, headers: ClientHeader?, body: JSON?)
    case bodyIsNotEncodable(headers: ClientHeader?)
    case responseDataIsNotDecodable(code: Int, headers: ClientHeader?, body: Data?)

    public var headers: ClientHeader? {
        switch self {
        case .requestFailed(_, let headers):
            return headers
        case .timeout(let headers):
            return headers
        case .statusCodeNotFound(let headers):
            return headers
        case .statusCodeNot2XX(_, let headers, _):
            return headers
        case .bodyIsNotEncodable(let headers):
            return headers
        case .responseDataIsNotDecodable(_, let headers, _):
            return headers
        }
    }
}
