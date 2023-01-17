//
//  DictionaryStorageProtocol.swift
//  AppleStorage
//
//  Created by WOF on 2022/09/06.
//

import SabyConcurrency

extension DictionaryStorage {
    public typealias SelfProtocol = DictionaryStorage<Self.Key, Self.Value>
    public typealias AnyProtocol = any DictionaryStorage<Self.Key, Self.Value>
}
