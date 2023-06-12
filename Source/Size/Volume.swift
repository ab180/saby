//
//  Volume.swift
//  SabySize
//
//  Created by WOF on 2023/06/12.
//

import Foundation

public struct Volume: Codable, Comparable, Equatable {
    public let byte: Double
    
    init(byte: Double) {
        self.byte = byte
    }
}

extension Volume {
    public static func byte(_ byte: Double) -> Volume {
        Volume(byte: byte)
    }
    
    public static func kibibyte(_ kibibyte: Double) -> Volume {
        Volume(byte: kibibyte * 1024)
    }
    
    public static func mebibyte(_ mebibyte: Double) -> Volume {
        Volume(byte: mebibyte * 1024 * 1024)
    }
    
    public static func gibibyte(_ gibibyte: Double) -> Volume {
        Volume(byte: gibibyte * 1024 * 1024 * 1024)
    }
    
    public static func tebibyte(_ tebibyte: Double) -> Volume {
        Volume(byte: tebibyte * 1024 * 1024 * 1024 * 1024)
    }
}

extension Volume {
    public static func +(left: Volume, right: Volume) -> Volume {
        Volume(byte: left.byte + right.byte)
    }
    
    public static func -(left: Volume, right: Volume) -> Volume {
        Volume(byte: left.byte - right.byte)
    }
    
    public static func <(left: Volume, right: Volume) -> Bool {
        left.byte < right.byte
    }
}

extension Volume {
    public var kibibyte: Double {
        byte / 1024
    }
    
    public var mebibyte: Double {
        byte / 1024 / 1024
    }
    
    public var gibibyte: Double {
        byte / 1024 / 1024 / 1024
    }
    
    public var tebibyte: Double {
        byte / 1024 / 1024 / 1024 / 1024
    }
}
