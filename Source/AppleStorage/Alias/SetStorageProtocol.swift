//
//  SetStorageProtocol.swift
//  SabyAppleStorage
//

import Foundation

extension SetStorage {
    public typealias SelfProtocol = SetStorage<Self.Value>
    public typealias AnyProtocol = any SetStorage<Self.Value>
}
