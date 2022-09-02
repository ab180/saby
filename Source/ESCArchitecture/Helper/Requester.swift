//
//  Requester.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

public protocol Requester {
    associatedtype Command
    associatedtype Value
    
    func request(_ command: Command) -> Promise<Value>
}
