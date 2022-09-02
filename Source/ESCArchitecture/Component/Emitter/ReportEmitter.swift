//
//  ReportEmitter.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

open class ReportEmitter<State>: Emitter {
    let resolve: (State) -> Void
    let reject: (Error) -> Void
    
    public let contract: Contract<State>
    
    public init() {
        let (contract, resolve, reject) = Contract<State>.create()
        
        self.resolve = resolve
        self.reject = reject
        
        self.contract = contract
    }
    
    public func report(state: State) {
        resolve(state)
    }
}
