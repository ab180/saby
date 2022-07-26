//
//  Service.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/03.
//

public protocol Service<Command, Result> {
    associatedtype Command
    associatedtype Result
    
    func handle(_ command: Command) -> Result
}
