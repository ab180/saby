//
//  EntitlementFetcher.swift
//  Saby
//
//  Created by WOF on 5/22/25.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation
import MachO

import SabyConcurrency

public final class EntitlementFetcher: Fetcher {
    public typealias Value = Promise<Entitlement, Error>
    
    public func fetch() -> Promise<Entitlement, Error> {
        return Promise.async {
            guard
                let name = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String,
                let path = Bundle.main.path(forResource: name, ofType: nil)
            else {
                throw EntitlementFetcherError.openingExectuableFailed
            }
            
            return try self.fetch(path: path)
        }
    }
}

public typealias Entitlement = [String: Any]

public enum EntitlementKey: String {
    case appGroups = "com.apple.security.application-groups"
    case apsEnvironment = "aps-environment"
    case associatedDomains = "com.apple.developer.associated-domains"
    case applicationIdentifier = "application-identifier"
}

public enum EntitlementFetcherError: Error {
    case openingExectuableFailed
    case readingExectuableFailed
    case readingHeaderFailed
    case readingLoadCommandFailed
    case readingCodeSignatureFailed
    case readingTextSegmentFailed
}

extension EntitlementFetcher {
    func fetch(path: String) throws -> Entitlement {
        guard let reader = ExecutableReader(path: path) else {
            throw EntitlementFetcherError.openingExectuableFailed
        }
        
        let commandCount = try reader.readHeader()
        let (codeSignatureIndex, textSegmentIndex) = try reader.readLoadCommand(count: commandCount)
        
        return try (
            reader.readTextSegment(index: textSegmentIndex)
            ?? reader.readCodeSignature(index: codeSignatureIndex)
        )
    }
}

extension ExecutableReader {
    func readHeader() throws -> UInt64 {
        let header = try read(type: mach_header.self)
        let commandCount = header.ncmds
        switch header.magic {
        case MH_MAGIC:
            try seek(offset: UInt64(MemoryLayout<mach_header>.size))
        case MH_MAGIC_64:
            try seek(offset: UInt64(MemoryLayout<mach_header_64>.size))
        default:
            throw EntitlementFetcherError.readingHeaderFailed
        }
        
        return UInt64(commandCount)
    }
    
    struct CodeSignatureIndex {
        let offset: UInt64
    }
    
    struct TextSegmentIndex {
        let dataOffset: UInt64
        let sectionOffset: UInt64
        let sectionCount: UInt64
    }
    
    func readLoadCommand(count: UInt64) throws -> (CodeSignatureIndex, TextSegmentIndex) {
        var codeSignatureIndex: CodeSignatureIndex?
        var textSegmentIndex: TextSegmentIndex?
        
        for _ in 0 ..< count {
            let command = try read(type: load_command.self)
            let commandBodySize = UInt64(command.cmdsize) - UInt64(MemoryLayout<load_command>.size)
            let currentOffset = try offset() - UInt64(MemoryLayout<load_command>.size)
            let nextOffset = try offset() + commandBodySize
            
            if command.cmd == LC_CODE_SIGNATURE {
                codeSignatureIndex = CodeSignatureIndex(
                    offset: UInt64(try read(type: UInt32.self))
                )
            }
            else if command.cmd == LC_SEGMENT_64 {
                try seek(offset: currentOffset)
                let command = try read(type: segment_command_64.self)
                let segmentName = withUnsafePointer(to: command.segname) {
                    $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                        String(cString: $0)
                    }
                }
                if segmentName == "__TEXT" {
                    textSegmentIndex = TextSegmentIndex(
                        dataOffset: command.fileoff,
                        sectionOffset: try offset(),
                        sectionCount: UInt64(command.nsects)
                    )
                }
            }
            if command.cmd == LC_CODE_SIGNATURE || command.cmd == LC_SEGMENT_64 {
                if let codeSignatureIndex, let textSegmentIndex {
                    return (codeSignatureIndex, textSegmentIndex)
                }
            }
            
            try seek(offset: nextOffset)
        }
        throw EntitlementFetcherError.readingLoadCommandFailed
    }
    
    struct BlobMetaHeader {
        let magic: UInt32
        let length: UInt32
        let count: UInt32
    }
    
    struct BlobHeader {
        let type: UInt32
        let offset: UInt32
    }
    
    struct Blob {
        let magic: UInt32
        let length: UInt32
    }
    
    enum BlobMagic: UInt32 {
        case codeSignature = 0xfade0cc0
        case entitlement = 0xfade7171
    }
    
    func readCodeSignature(index: CodeSignatureIndex) throws -> Entitlement {
        let offset = index.offset
        try seek(offset: offset)
        
        let metaHeader = try read(type: BlobMetaHeader.self)
        let metaHeaderSize = UInt32(MemoryLayout<BlobMetaHeader>.size)
        let metaHeaderMagic = CFSwapInt32(metaHeader.magic)
        guard metaHeaderMagic == BlobMagic.codeSignature.rawValue else {
            throw EntitlementFetcherError.readingCodeSignatureFailed
        }
        
        let headerSize = UInt32(MemoryLayout<BlobHeader>.size)
        let headerCount = CFSwapInt32(metaHeader.count)
        let blobSize = UInt32(MemoryLayout<Blob>.size)
        
        for index in 0 ..< headerCount {
            try seek(offset: offset + UInt64(metaHeaderSize + index * headerSize))
            let header = try read(type: BlobHeader.self)
            
            try seek(offset: offset + UInt64(CFSwapInt32(header.offset)))
            let blob = try read(type: Blob.self)
            let blobMagic = CFSwapInt32(blob.magic)
            
            if blobMagic == BlobMagic.entitlement.rawValue {
                let entitlementSize = CFSwapInt32(blob.length)
                let entitlementData = try read(length: Int(entitlementSize - blobSize))
                
                guard
                    let entitlement = try? PropertyListSerialization.propertyList(
                        from: entitlementData,
                        format: nil
                    ) as? [String: Any]
                else {
                    throw EntitlementFetcherError.readingCodeSignatureFailed
                }
                
                return entitlement
            }
        }
        
        throw EntitlementFetcherError.readingCodeSignatureFailed
    }
    
    func readTextSegment(index: TextSegmentIndex) throws -> Entitlement? {
        let dataOffset = index.dataOffset
        let sectionOffset = index.sectionOffset
        try seek(offset: sectionOffset)
        
        let sectionSize = UInt64(MemoryLayout<section_64>.size)
        
        for index in 0 ..< index.sectionCount {
            try seek(offset: sectionOffset + UInt64(index * sectionSize))
            let section = try read(type: section_64.self)
            
            let sectionName = withUnsafePointer(to: section.sectname) {
                $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                    String(cString: $0)
                }
            }
            if sectionName == "__entitlements" {
                let sectionDataOffset = UInt64(section.offset)
                let entitlementOffset = dataOffset + sectionDataOffset
                let entitlementSize = section.size
                
                try seek(offset: entitlementOffset)
                let entitlementData = try read(length: Int(entitlementSize))
                
                guard
                    let entitlement = try? PropertyListSerialization.propertyList(
                        from: entitlementData,
                        format: nil
                    ) as? [String: Any]
                else {
                    throw EntitlementFetcherError.readingTextSegmentFailed
                }
                
                return entitlement
            }
        }
        
        return nil
    }
}

private final class ExecutableReader {
    let file: FileHandle
    
    init?(path: String) {
        guard let file = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        
        self.file = file
    }
    
    deinit {
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            try? file.close()
        }
        else {
            file.closeFile()
        }
    }
}

extension ExecutableReader {
    func offset() throws -> UInt64 {
        if #available(iOS 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
            do {
                return try file.offset()
            }
            catch {
                throw EntitlementFetcherError.readingExectuableFailed
            }
        }
        else {
            return file.offsetInFile
        }
    }
    
    func seek(offset: UInt64) throws {
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) {
            do {
                try file.seek(toOffset: offset)
            }
            catch {
                throw EntitlementFetcherError.readingExectuableFailed
            }
        }
        else {
            file.seek(toFileOffset: offset)
        }
    }
    
    func read<Value>(type: Value.Type) throws -> Value {
        return try read(length: MemoryLayout<Value>.size).withUnsafeBytes {
            return $0.load(as: type)
        }
    }
    
    func read(length: Int) throws -> Data {
        if #available(iOS 13.4, macOS 10.15.4, tvOS 13.4, watchOS 6.2, *) {
            guard let data = try? file.read(upToCount: length) else {
                throw EntitlementFetcherError.readingExectuableFailed
            }
            
            return data
        }
        else {
            let data = file.readData(ofLength: length)
            if (data.count < length) {
                throw EntitlementFetcherError.readingExectuableFailed
            }
            
            return data
        }
    }
}

#endif
