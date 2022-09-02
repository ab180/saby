//
//  Accessor.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

public typealias Accessor = Reader & Writer

public protocol Reader {
    associatedtype Command
    associatedtype Value
    
    func read(_ command: Command) -> Value
}

public protocol Writer {
    associatedtype Command
    
    func write(_ command: Command) -> Void
}
