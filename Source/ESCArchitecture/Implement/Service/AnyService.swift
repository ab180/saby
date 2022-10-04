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
    let serviceBox: AnyServiceBoxBase<Command, Result>
    
    @inline(__always) @inlinable
    public init<ActualService: Service>(_ service: ActualService) where
        ActualService.Command == Command,
        ActualService.Result == Result
    {
        if let anyService = service as? AnyService<Command, Result> {
            self.serviceBox = anyService.serviceBox
        }
        else {
            self.serviceBox = AnyServiceBox(service)
        }
    }
    
    @inline(__always) @inlinable
    public func handle(_ command: Command) -> Result {
        serviceBox.handle(command)
    }
}

@usableFromInline
class AnyServiceBoxBase<Command, Result>: Service {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func handle(_ command: Command) -> Result { fatalError() }
}

@usableFromInline
final class AnyServiceBox<ActualService: Service>: AnyServiceBoxBase<
    ActualService.Command,
    ActualService.Result
> {
    @usableFromInline
    let service: ActualService
    
    @inline(__always) @inlinable
    init(_ service: ActualService) {
        self.service = service
    }

    @inline(__always) @inlinable
    override func handle(_ command: Command) -> Result {
        service.handle(command)
    }
}
