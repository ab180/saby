//
//  AnyRepository.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/05.
//

extension Repository {
    public typealias Repository = SabyESCArchitecture.Repository<Self.Query, Self.Result>
    public typealias AnyRepository = any SabyESCArchitecture.Repository<Self.Query, Self.Result>
}
