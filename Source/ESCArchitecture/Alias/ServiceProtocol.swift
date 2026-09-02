//
//  ServiceProtocol.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/03.
//

extension Service {
    public typealias AnyProtocol = any Service<Self.Command, Self.Result>
}
