//
//  Fetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/22.
//

import Foundation

protocol Fetcher {
    associatedtype Value
    
    func fetch() -> Value
}
