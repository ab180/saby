//
//  Emitter.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

public protocol Emitter<Value, Failure> {
    associatedtype Value
    associatedtype Failure: Error
    
    var contract: Contract<Value, Failure> { get }
}
