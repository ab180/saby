//
//  PromiseConvert.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/08/25.
//

import Foundation

extension Promise {
    func toPromiseVoid() -> Promise<Void> {
        self.then { _ in }
    }
    
    func toPromiseAny() -> Promise<Any> {
        self.then { $0 }
    }
}
