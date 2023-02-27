//
//  Signaler.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

public protocol Signaler<Value, Failure> {
    associatedtype Value
    associatedtype Failure: Error
    
    var promise: Promise<Value, Failure> { get }
}
