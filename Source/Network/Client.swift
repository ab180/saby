//
//  Client.swift
//  SabyNetwork
//
//  Created by WOF on 2022/08/16.
//

import Foundation

import SabyConcurrency

public protocol Client {
    associatedtype Request
    associatedtype Response
    
    func request(
        _ url: URL,
        method: ClientMethod,
        header: ClientHeader,
        body: Request,
        optionBlock: (inout URLRequest) -> Void
    ) -> Promise<Response>
}

public enum ClientMethod: String {
    case get = "GET"
    case post = "POST"
}

public typealias ClientHeader = Dictionary<String, String>
