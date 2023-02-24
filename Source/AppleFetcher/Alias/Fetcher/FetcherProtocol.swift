//
//  FetcherProtocol.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/09/02.
//

import Foundation

extension Fetcher {
    public typealias SelfProtocol = Fetcher<Self.Value>
    public typealias AnyProtocol = any Fetcher<Self.Value>
}
