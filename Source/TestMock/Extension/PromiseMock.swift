//
//  PromiseMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/06.
//

import Foundation

import SabyConcurrency

extension Promise: Mockable where Value: Mockable {
    public static func mock() -> Promise<Value, Failure> {
        return Promise<Value, Failure>.resolved(Value.mock())
    }
}
