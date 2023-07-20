//
//  SignalerProtocol.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2023/07/20.
//

extension Signaler {
    public typealias SelfProtocol = Signaler<Self.Value, Self.Failure>
    public typealias AnyProtocol = any Signaler<Self.Value, Self.Failure>
}
