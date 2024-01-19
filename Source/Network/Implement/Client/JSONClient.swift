//
//  JSONClient.swift
//  SabyRequest
//
//  Created by WOF on 2022/08/16.
//

import Foundation

import SabyConcurrency
import SabySafe
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
    public convenience init(optionBlock: (inout URLSessionConfiguration) -> Void = { _ in }) {
        let client = DataClient(optionBlock: optionBlock)
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
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<JSON>, Error> {
        guard let body = try? body?.datafy() else {
            return Promise.rejected(JSONClientError.bodyIsNotEncodable)
        }
        
        return client.request(
            url: url,
            method: method,
            header: header,
            body: body,
            timeout: timeout,
            optionBlock: optionBlock
        )
        .then { code2XX, data -> ClientResult<JSON> in
            guard let data, let body = try? JSON.parse(data) else {
                throw JSONClientError.responseDataIsNotDecodable(code: code2XX, data: data)
            }
            
            
            return (code2XX, body)
        }
        .catch { error in
            if case DataClientError.timeout = error {
                throw JSONClientError.timeout
            }
            else if case DataClientError.statusCodeNotFound = error {
                throw JSONClientError.statusCodeNotFound
            }
            else if case DataClientError.statusCodeNot2XX(let codeNot2XX, let data) = error {
                guard let data, let body = try? JSON.parse(data) else {
                    throw JSONClientError.responseDataIsNotDecodable(code: codeNot2XX, data: data)
                }
                throw JSONClientError.statusCodeNot2XX(codeNot2XX: codeNot2XX, body: body)
            }
        }
    }
}

public enum JSONClientError: Error {
    case timeout
    case statusCodeNotFound
    case statusCodeNot2XX(codeNot2XX: Int, body: JSON)
    case bodyIsNotEncodable
    case responseDataIsNotDecodable(code: Int, data: Data?)
}
