//
//  Producer.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import Foundation

public protocol Producer {
    associatedtype Command
    associatedtype Value
    
    func produce(_ command: Command) -> Value
}
