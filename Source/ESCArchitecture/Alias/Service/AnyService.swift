//
//  AnyService.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/03.
//

extension Service {
    public typealias Service = SabyESCArchitecture.Service<Self.Command, Self.Result>
    public typealias AnyService = any SabyESCArchitecture.Service<Self.Command, Self.Result>
}
