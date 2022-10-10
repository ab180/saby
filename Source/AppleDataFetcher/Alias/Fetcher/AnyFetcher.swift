//
//  Fetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/09/02.
//

import Foundation

extension Fetcher {
    public typealias Fetcher = SabyAppleDataFetcher.Fetcher<Self.Value>
    public typealias AnyFetcher = any SabyAppleDataFetcher.Fetcher<Self.Value>
}
