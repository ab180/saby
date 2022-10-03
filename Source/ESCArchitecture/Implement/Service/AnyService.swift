//
//  AnyService.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/03.
//

extension Service {
    @inline(__always) @inlinable
    public func toAnyService() -> AnyService<Command, Result> {
        AnyService(self)
    }
}

public struct AnyService<Command, Result>: Service {
    @usableFromInline
    let requesterBox: AnyServiceBoxBase<Command, Result>
    
    @inline(__always) @inlinable
    public init<ActualService: Service>(_ requester: ActualService) where
        ActualService.Command == Command,
        ActualService.Result == Result
    {
        if let anyService = requester as? AnyService<Command, Result> {
            self.requesterBox = anyService.requesterBox
        }
        else {
            self.requesterBox = AnyServiceBox(requester)
        }
    }
    
    @inline(__always) @inlinable
    public func request(_ command: Command) -> Result {
        requesterBox.request(command)
    }
}

@usableFromInline
class AnyServiceBoxBase<Command, Result>: Service {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func request(_ command: Command) -> Result { fatalError() }
}

@usableFromInline
final class AnyServiceBox<ActualService: Service>: AnyServiceBoxBase<
    ActualService.Command,
    ActualService.Result
> {
    @usableFromInline
    let requester: ActualService
    
    @inline(__always) @inlinable
    init(_ requester: ActualService) {
        self.requester = requester
    }

    @inline(__always) @inlinable
    override func request(_ command: Command) -> Result {
        requester.request(command)
    }
}
