//
//  AnyAccessor.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/09/02.
//

extension Reader {
    @inline(__always) @inlinable
    public func toAnyReader() -> AnyReader<Command, Value> {
        AnyReader(self)
    }
}

public struct AnyReader<Command, Value>: Reader {
    @usableFromInline
    let readerBox: AnyReaderBoxBase<Command, Value>
    
    @inline(__always) @inlinable
    public init<ActualReader: Reader>(_ reader: ActualReader) where
        ActualReader.Command == Command,
        ActualReader.Value == Value
    {
        if let anyReader = reader as? AnyReader<Command, Value> {
            self.readerBox = anyReader.readerBox
        }
        else {
            self.readerBox = AnyReaderBox(reader)
        }
    }
    
    @inline(__always) @inlinable
    public func read(_ command: Command) -> Value {
        readerBox.read(command)
    }
}

@usableFromInline
class AnyReaderBoxBase<Command, Value>: Reader {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func read(_ command: Command) -> Value { fatalError() }
}

@usableFromInline
final class AnyReaderBox<ActualReader: Reader>: AnyReaderBoxBase<
    ActualReader.Command,
    ActualReader.Value
> {
    @usableFromInline
    let reader: ActualReader
    
    @inline(__always) @inlinable
    init(_ reader: ActualReader) {
        self.reader = reader
    }

    @inline(__always) @inlinable
    override func read(_ command: Command) -> Value {
        reader.read(command)
    }
}

extension Writer {
    @inline(__always) @inlinable
    public func toAnyWriter() -> AnyWriter<Command> {
        AnyWriter(self)
    }
}

public struct AnyWriter<Command>: Writer {
    @usableFromInline
    let writerBox: AnyWriterBoxBase<Command>
    
    @inline(__always) @inlinable
    public init<ActualWriter: Writer>(_ writer: ActualWriter) where ActualWriter.Command == Command {
        if let anyWriter = writer as? AnyWriter<Command> {
            self.writerBox = anyWriter.writerBox
        }
        else {
            self.writerBox = AnyWriterBox(writer)
        }
    }
    
    @inline(__always) @inlinable
    public func write(_ command: Command) -> Void {
        writerBox.write(command)
    }
}

@usableFromInline
class AnyWriterBoxBase<Command>: Writer {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func write(_ command: Command) -> Void { fatalError() }
}

@usableFromInline
final class AnyWriterBox<ActualWriter: Writer>: AnyWriterBoxBase<ActualWriter.Command> {
    @usableFromInline
    let writer: ActualWriter
    
    @inline(__always) @inlinable
    init(_ writer: ActualWriter) {
        self.writer = writer
    }
    
    @inline(__always) @inlinable
    override func write(_ command: Command) -> Void {
        writer.write(command)
    }
}
