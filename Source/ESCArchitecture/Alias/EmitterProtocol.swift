//
//  EmitterProtocol.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2023/07/20.
//

extension Emitter {
    public typealias SelfProtocol = Emitter<Self.Value, Self.Failure>
    public typealias AnyProtocol = any Emitter<Self.Value, Self.Failure>
}
