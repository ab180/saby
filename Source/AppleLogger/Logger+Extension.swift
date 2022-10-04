//
//  File.swift
//  
//
//  Created by 이영빈 on 2022/09/30.
//

extension Logger {
    public func info(_ message: String) {
        self.log(level: .info, message)
    }
    
    public func debug(_ message: String) {
        self.log(level: .debug, message)
    }
    
    public func error(_ message: String) {
        self.log(level: .error, message)
    }
    
    public func falut(_ message: String) {
        self.log(level: .fault, message)
    }
}

