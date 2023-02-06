//
//  ReportEmitter.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

open class ReportEmitter<State>: Emitter {
    let resolve: (State) -> Void
    
    public let contract: Contract<State>
    
    public init() {
        let executing = Contract<State>.executing()
        
        self.resolve = executing.resolve
        
        self.contract = executing.contract
    }
    
    public func report(state: State) {
        resolve(state)
    }
}
