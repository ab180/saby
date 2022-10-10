//
//  AnyClient.swift
//  SabyNetwork
//
//  Created by WOF on 2022/09/02.
//

import Foundation

import SabyConcurrency

extension Client {
    public typealias Client = SabyNetwork.Client<Self.Request, Self.Response>
    public typealias AnyClient = any SabyNetwork.Client<Self.Request, Self.Response>
}
