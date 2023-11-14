//
//  DependencyFakeable.swift
//  SabyTestFake
//
//  Created by WOF on 11/13/23.
//

import Foundation

public protocol DependencyFakeable<Dependency> {
    associatedtype Dependency: Fakeable
    
    static func fake(dependency: Dependency) -> Self
}

extension DependencyFakeable {
    public static func fake(
        apply: (inout Dependency) -> Void = { _ in }
    ) -> (Self, Dependency) {
        var dependency = Dependency.fake()
        apply(&dependency)
        
        let instance = Self.fake(dependency: dependency)
        
        return (instance, dependency)
    }
}
