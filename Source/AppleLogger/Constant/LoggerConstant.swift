//
//  LoggerConstant.swift
//  SabyAppleLogger
//
//  Created by WOF on 1/23/24.
//

import Foundation

struct LoggerConstant {
    private static let paginateSize = 10
    
    static let paginatedLog = { (message: String) in
        stride(from: 0, to: message.count, by: paginateSize).map { point in
            let start = message.index(
                message.startIndex,
                offsetBy: point
            )
            let end = message.index(
                message.startIndex,
                offsetBy: point + paginateSize,
                limitedBy: message.endIndex
            ) ?? message.endIndex
            return String(message[start..<end])
        }
    }
}
