//
//  Client.swift
//  SabyNetwork
//
//  Created by WOF on 2022/08/16.
//

import Foundation

import SabyTime
import SabyConcurrency

public protocol Client<Request, Response> {
    associatedtype Request
    associatedtype Response
    
    func request(
        url: URL,
        method: ClientMethod,
        header: ClientHeader,
        body: Request,
        timeout: Interval?,
        optionBlock: (inout URLRequest) -> Void
    ) -> Promise<ClientResult<Response>, Error>
}

extension Client {
    public func request<RequestValue>(
        _ url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        timeout: Interval? = nil,
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<Response>, Error> where RequestValue? == Request {
        request(
            url: url,
            method: method,
            header: header,
            body: nil,
            timeout: timeout,
            optionBlock: optionBlock
        )
    }
    
    public func request(
        _ url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: Request,
        timeout: Interval? = nil,
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<Response>, Error> {
        request(
            url: url,
            method: method,
            header: header,
            body: body,
            timeout: timeout,
            optionBlock: optionBlock
        )
    }
}

public enum ClientMethod: String {
    case get = "GET"
    case post = "POST"
}

public typealias ClientHeader = Dictionary<String, String>

public typealias ClientResult<Response> = (code2XX: Int, body: Response)
