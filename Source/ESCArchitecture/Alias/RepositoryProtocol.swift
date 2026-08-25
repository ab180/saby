//
//  RepositoryProtocol.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/05.
//

extension Repository {
    public typealias AnyProtocol = any Repository<Self.Query, Self.Result>
}
