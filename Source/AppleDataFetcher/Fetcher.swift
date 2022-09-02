//
//  Fetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/22.
//

import Foundation

public protocol Fetcher {
    associatedtype Value
    
    func fetch() -> Value
}
