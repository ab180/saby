//
//  ClientProtocol.swift
//  SabyNetwork
//
//  Created by WOF on 2022/09/02.
//

import Foundation

import SabyConcurrency

extension Client {
    public typealias SelfProtocol = Client<Self.Request, Self.Response>
    public typealias AnyProtocol = any Client<Self.Request, Self.Response>
}
