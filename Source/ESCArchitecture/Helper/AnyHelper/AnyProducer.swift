//
//  AnyProducer.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

import Foundation

extension Producer {
    @inline(__always) @inlinable
    public func toAnyProducer() -> AnyProducer<Command, Value> {
        AnyProducer(self)
    }
}

public struct AnyProducer<Command, Value>: Producer {
    @usableFromInline
    let producerBox: AnyProducerBoxBase<Command, Value>
    
    @inline(__always) @inlinable
    public init<ActualProducer: Producer>(_ producer: ActualProducer) where
        ActualProducer.Command == Command,
        ActualProducer.Value == Value
    {
        if let anyProducer = producer as? AnyProducer<Command, Value> {
            self.producerBox = anyProducer.producerBox
        }
        else {
            self.producerBox = AnyProducerBox(producer)
        }
    }
    
    @inline(__always) @inlinable
    public func produce(_ command: Command) -> Value {
        producerBox.produce(command)
    }
}

@usableFromInline
class AnyProducerBoxBase<Command, Value>: Producer {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func produce(_ command: Command) -> Value { fatalError() }
}

@usableFromInline
final class AnyProducerBox<ActualProducer: Producer>: AnyProducerBoxBase<
    ActualProducer.Command,
    ActualProducer.Value
> {
    @usableFromInline
    let producer: ActualProducer
    
    @inline(__always) @inlinable
    init(_ producer: ActualProducer) {
        self.producer = producer
    }

    @inline(__always) @inlinable
    override func produce(_ command: Command) -> Value {
        producer.produce(command)
    }
}
