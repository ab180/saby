//
//  JSONClient.swift
//  SabyRequest
//
//  Created by WOF on 2022/08/16.
//

import Foundation

import SabyConcurrency
import SabyJSON
import SabySafe

public final class JSONClient<Request: Encodable, Response: Decodable>: Client {
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
    public func request<RequestValue>(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<Response> where RequestValue? == Request {
        request(url: url, method: method, header: header, body: nil, optionBlock: optionBlock)
    }
    
    public func request(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: Request,
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<Response> {
        guard let json = try? JSON.encode(body) else {
            return Promise<Response>.rejected(InternalError.bodyIsNotEncodable)
        }
        
        let data = try? json.datafy()
        if !json.isNull, data == nil {
            return Promise<Response>.rejected(InternalError.bodyJSONIsNotDatafiable)
        }
        let body = data
        
        return client.request(
            url: url,
            method: method,
            header: header,
            body: body,
            optionBlock: optionBlock
        ).then { data -> Response in
            if
                (Response.self is Data.Type || Response.self is Data?.Type),
                let result = data as? Response
            {
                return result
            }
            
            guard
                let data = data,
                let result = try? self.decoder.decode(Response.self, from: data)
            else {
                throw InternalError.responseDataIsNotDecodable
            }
            
            return result
        }
    }
}

extension JSONClient {
    public enum InternalError: Error {
        case responseDataIsNotDecodable
        case bodyIsNotEncodable
        case bodyJSONIsNotDatafiable
    }
}
