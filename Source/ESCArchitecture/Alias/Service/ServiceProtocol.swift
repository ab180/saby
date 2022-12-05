//
//  ServiceProtocol.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/03.
//

extension Service {
    public typealias SelfProtocol = Service<Self.Command, Self.Result>
    public typealias AnyProtocol = any Service<Self.Command, Self.Result>
}
