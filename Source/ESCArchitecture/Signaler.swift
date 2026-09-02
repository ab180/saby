//
//  Signaler.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

public protocol Signaler<Value, Failure>: Sendable {
    associatedtype Value: Sendable
    associatedtype Failure: Error & Sendable
    
    var promise: Promise<Value, Failure> { get }
}
