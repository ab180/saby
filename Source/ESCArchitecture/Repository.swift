//
//  Repository.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/05.
//

public protocol Repository<Query, Result> {
    associatedtype Query
    associatedtype Result
    
    func request(_ query: Query) -> Result
}
