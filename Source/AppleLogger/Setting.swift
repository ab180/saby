//
//  LoggerConfiguration.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

import OSLog

extension Logger {
    public struct Setting {
        /// A default logger configuration object
        public static var `default`: Logger.Setting {
            Setting()
        }
        
        /// A variable indicating logger's logging level. Set  to `.none` to not show logs.
        public var logLevel: LogLevel? = .debug
        
        /// Use `print` to show logs  instead of `OS_log` when set to `true`
        public var usePrint: Bool = false
        
        /// A variable used for displaying `subsystem` value in console
        public var subsystem: String? {
            didSet {
                osLog = OSLog(subsystem: subsystem ?? "", category: category ?? "")
            }
        }
        
        /// A variable used for displaying `category` value in console
        public var category: String? {
            didSet {
                osLog = OSLog(subsystem: subsystem ?? "", category: category ?? "")
            }
        }
        
        /// An internal variable used to execute `os_log`
        var osLog: OSLog?
        
        public init() {}
        
        public init(subsystem: String, category: String) {
            self.subsystem = subsystem
            self.category = category
        }
    }
}
