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

public final class JSONClient<Result: Decodable>: Client {
    public typealias Request = JSON?
    public typealias Response = Result
    
    let client: DataClient
    let decoder: JSONDecoder
    
    init(client: DataClient, decoder: JSONDecoder) {
        self.client = client
        self.decoder = decoder
    }
}

extension JSONClient {
    public convenience init(optionBlock: (inout URLSessionConfiguration) -> Void = { _ in }) {
        let client = DataClient(optionBlock: optionBlock)
        let decoder = JSONDecoder()
        self.init(client: client, decoder: decoder)
    }
}

extension JSONClient {
    public func request(
        _ url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: JSON? = nil,
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<Result> {
        guard let body = (optDo {
            try body?.datafy() ?? Data()
        }) else {
            return Promise<Result>.rejected(InternalError.bodyJSONIsNotDatafiable)
        }
        
        return client.request(
            url,
            method: method,
            header: header,
            body: body,
            optionBlock: optionBlock
        ).then { data -> Result in
            guard
                let data = data,
                let result = try? self.decoder.decode(Result.self, from: data)
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
        case bodyJSONIsNotDatafiable
    }
}
