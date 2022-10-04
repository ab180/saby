//
//  Repository.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/05.
//

public protocol Repository {
    associatedtype Query
    associatedtype Result
    
    func request(_ command: Query) -> Result
}
