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

public final class JSONClient: Client {
    let client: DataClient
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    
    init(
        client: DataClient,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.client = client
        self.encoder = encoder
        self.decoder = decoder
    }
}

extension JSONClient {
    public convenience init(optionBlock: (inout URLSessionConfiguration) -> Void = { _ in }) {
        let client = DataClient(optionBlock: optionBlock)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        self.init(client: client, encoder: encoder, decoder: decoder)
    }
}
    
extension JSONClient {
    public func request(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: JSON? = nil,
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<JSON>, Error> {
        guard let body = try? self.encoder.encode(body) else {
            return Promise.rejected(JSONClientError.bodyIsNotEncodable)
        }
        
        return client.request(
            url: url,
            method: method,
            header: header,
            body: body,
            optionBlock: optionBlock
        )
        .then { code2XX, data -> ClientResult<JSON> in
            guard let data, let body = try? JSON.parse(data) else {
                throw JSONClientError.responseDataIsNotDecodable
            }
            
            
            return (code2XX, body)
        }
        .catch { error in
            if case DataClientError.statusCodeNotFound = error {
                throw JSONClientError.statusCodeNotFound
            }
            else if case DataClientError.statusCodeNot2XX(let codeNot2XX, let data) = error {
                guard let data, let body = try? JSON.parse(data) else {
                    throw JSONClientError.responseDataIsNotDecodable
                }
                throw JSONClientError.statusCodeNot2XX(codeNot2XX: codeNot2XX, body: body)
            }
        }
    }
}

public enum JSONClientError: Error {
    case statusCodeNotFound
    case statusCodeNot2XX(codeNot2XX: Int, body: JSON)
    case bodyIsNotEncodable
    case responseDataIsNotDecodable
}
