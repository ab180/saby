//
//  AnyRequester.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import SabyConcurrency

extension Requester {
    @inline(__always) @inlinable
    public func toAnyRequester() -> AnyRequester<Command, Value> {
        AnyRequester(self)
    }
}

public struct AnyRequester<Command, Value>: Requester {
    @usableFromInline
    let requesterBox: AnyRequesterBoxBase<Command, Value>
    
    @inline(__always) @inlinable
    public init<ActualRequester: Requester>(_ requester: ActualRequester) where
        ActualRequester.Command == Command,
        ActualRequester.Value == Value
    {
        if let anyRequester = requester as? AnyRequester<Command, Value> {
            self.requesterBox = anyRequester.requesterBox
        }
        else {
            self.requesterBox = AnyRequesterBox(requester)
        }
    }
    
    @inline(__always) @inlinable
    public func request(_ command: Command) -> Promise<Value> {
        requesterBox.request(command)
    }
}

@usableFromInline
class AnyRequesterBoxBase<Command, Value>: Requester {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func request(_ command: Command) -> Promise<Value> { fatalError() }
}

@usableFromInline
final class AnyRequesterBox<ActualRequester: Requester>: AnyRequesterBoxBase<
    ActualRequester.Command,
    ActualRequester.Value
> {
    @usableFromInline
    let requester: ActualRequester
    
    @inline(__always) @inlinable
    init(_ requester: ActualRequester) {
        self.requester = requester
    }

    @inline(__always) @inlinable
    override func request(_ command: Command) -> Promise<Value> {
        requester.request(command)
    }
}
