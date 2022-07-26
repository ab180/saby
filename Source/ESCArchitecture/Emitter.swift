//
//  Emitter.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

public protocol Emitter<State> {
    associatedtype State
    
    var contract: Contract<State> { get }
}
