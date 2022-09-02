//
//  AnyClient.swift
//  SabyNetwork
//
//  Created by WOF on 2022/09/02.
//

import Foundation

import SabyConcurrency

extension Client {
    @inline(__always) @inlinable
    public func toAnyClient() -> AnyClient<Request, Response> {
        AnyClient(self)
    }
}

public struct AnyClient<Request, Response>: Client {
    @usableFromInline
    let clientBox: AnyClientBoxBase<Request, Response>
    
    @inline(__always) @inlinable
    public init<ActualClient: Client>(_ client: ActualClient) where
        ActualClient.Request == Request,
        ActualClient.Response == Response
    {
        if let anyClient = client as? AnyClient<Request, Response> {
            self.clientBox = anyClient.clientBox
        }
        else {
            self.clientBox = AnyClientBox(client)
        }
    }
    
    @inline(__always) @inlinable
    public func request(
        _ url: URL,
        method: ClientMethod,
        header: ClientHeader,
        body: Request,
        optionBlock: (inout URLRequest) -> Void
    ) -> Promise<Response> {
        clientBox.request(
            url,
            method: method,
            header: header,
            body: body,
            optionBlock: optionBlock
        )
    }
}

@usableFromInline
class AnyClientBoxBase<Request, Response>: Client {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func request(
        _ url: URL,
        method: ClientMethod,
        header: ClientHeader,
        body: Request,
        optionBlock: (inout URLRequest) -> Void
    ) -> Promise<Response> {
        fatalError()
    }
}

@usableFromInline
final class AnyClientBox<ActualClient: Client>: AnyClientBoxBase<
    ActualClient.Request,
    ActualClient.Response
> {
    @usableFromInline
    let client: ActualClient
    
    @inline(__always) @inlinable
    init(_ client: ActualClient) {
        self.client = client
    }

    @inline(__always) @inlinable
    override func request(
        _ url: URL,
        method: ClientMethod,
        header: ClientHeader,
        body: Request,
        optionBlock: (inout URLRequest) -> Void
    ) -> Promise<Response> {
        client.request(
            url,
            method: method,
            header: header,
            body: body,
            optionBlock: optionBlock
        )
    }
}
