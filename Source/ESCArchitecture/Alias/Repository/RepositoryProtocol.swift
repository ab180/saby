//
//  RepositoryProtocol.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/05.
//

extension Repository {
    public typealias SelfProtocol = Repository<Self.Query, Self.Result>
    public typealias AnyProtocol = any Repository<Self.Query, Self.Result>
}
