//
//  File.swift
//  
//
//  Created by 이영빈 on 2022/09/30.
//

import OSLog

extension OSLog {
    static let subsystem = "AirBridge"
    
    static let `default` = OSLog(subsystem: subsystem, category: "AirBridge: Default")
    static let info = OSLog(subsystem: subsystem, category: "AirBridge: Info")
    static let error = OSLog(subsystem: subsystem, category: "AirBridge: Error")
    static let falut = OSLog(subsystem: subsystem, category: "AirBridge: Falut")
    
    /// Another possible use case for `OSLog`'s category
//    static let network = OSLog(subsystem: subsystem, category: "Network")
}

