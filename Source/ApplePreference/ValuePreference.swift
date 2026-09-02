//
//  ValuePreference.swift
//  SabyApplePreference
//
//  Created by WOF on 2023/10/12.
//

import Foundation

public protocol ValuePreference<Value>: Preference, Sendable {
    associatedtype Value: Sendable
    
    func set(_ value: Value) async throws -> Void
    func clear() async throws -> Void
    func get() async throws -> Value?
    func save() async throws -> Void
}
