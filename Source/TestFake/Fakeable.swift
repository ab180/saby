//
//  Fakeable.swift
//  SabyTestFake
//
//  Created by WOF on 11/8/23.
//

import Foundation

public protocol Fakeable<Dependency> {
    associatedtype Dependency: FakeDependency
    
    init(dependency: Dependency)
}

extension Fakeable {
    static func fake(apply: (inout Dependency) -> Void) -> (Self, Dependency) {
        var dependency = Dependency()
        apply(&dependency)
        
        let instance = Self(dependency: dependency)
        
        return (instance, dependency)
    }
}
