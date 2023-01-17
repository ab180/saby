//
//  AnyArrayStorageProtocol.swift
//  AppleStorage
//
//  Created by WOF on 2022/09/06.
//

import SabyConcurrency

extension ArrayStorage {
    public typealias SelfProtocol = ArrayStorage<Self.Value>
    public typealias AnyProtocol = any ArrayStorage<Self.Value>
}
