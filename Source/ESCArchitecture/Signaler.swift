//
//  Signaler.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

public protocol Signaler<State> {
    associatedtype State
    
    var promise: Promise<State> { get }
}
