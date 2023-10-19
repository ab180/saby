//
//  ValuePreference.swift
//  SabyApplePreference
//
//  Created by WOF on 2023/10/12.
//

import Foundation

public protocol ValuePreference<Value>: Preference {
    associatedtype Value
    
    func set(_ value: Value) throws -> Void
    func clear() throws -> Void
    func get() throws -> Value?
    func save() throws -> Void
}
