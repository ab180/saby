//
//  KeyIdentifiable.swift
//  SabyAppleStorage
//
//  Created by WOF on 2022/08/25.
//

import Foundation

public protocol KeyIdentifiable {
    associatedtype Key: Hashable, CustomStringConvertible
    
    var key: Key { get }
}
