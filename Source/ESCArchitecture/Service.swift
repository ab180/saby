//
//  Service.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/03.
//

public protocol Service {
    associatedtype Command
    associatedtype Result
    
    func request(_ command: Command) -> Result
}
