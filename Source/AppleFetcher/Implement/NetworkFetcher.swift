//
//  NetworkFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation
import SystemConfiguration

import SabyConcurrency

public final class NetworkFetcher: Fetcher {
    public typealias Value = Network
    
    public init() {}

    public func fetch() -> Network {
        let ipList = fetchIPList()
        let type = fetchType()
        
        return Network(
            ip: ipList,
            isCellular: type == .cellular,
            isWiFi: type == .wifi
        )
    }
}

public struct InterfaceType: Hashable {
    let name: String
    let family: sa_family_t
}

public struct IP {
    public let ip: String
    public let interfaceType: InterfaceType
}

public struct Network {
    public let ip: [IP]
    public let isCellular: Bool
    public let isWiFi: Bool
}

extension NetworkFetcher {
    private func fetchIPList() -> [IP] {
        
        var ipStorage: [InterfaceType: String] = [:]
        
        var interfacesPointer: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfacesPointer) == 0 else { return [] }
        guard let interfaceFirstPointer = interfacesPointer else { return [] }
        
        for interfacePointer in sequence(
            first: interfaceFirstPointer,
            next: { $0.pointee.ifa_next }
        ) {
            let interface = interfacePointer.pointee
            
            let interfaceType = InterfaceType(
                name: String(cString: interface.ifa_name),
                family: interface.ifa_addr.pointee.sa_family
            )
            let ip = { () -> String in
                var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(
                    interface.ifa_addr,
                    socklen_t(interface.ifa_addr.pointee.sa_len),
                    &buffer,
                    socklen_t(buffer.count),
                    nil,
                    socklen_t(0),
                    NI_NUMERICHOST
                )
                return String(cString: buffer)
            }()
            
            ipStorage[interfaceType] = ip
        }
        
        freeifaddrs(interfacesPointer)
        
        let searchs = [
            InterfaceType(name: "en0", family: sa_family_t(AF_INET)),
            InterfaceType(name: "en0", family: sa_family_t(AF_INET6)),
            InterfaceType(name: "pdp_ip0", family: sa_family_t(AF_INET)),
            InterfaceType(name: "pdp_ip0", family: sa_family_t(AF_INET6)),
            InterfaceType(name: "utun0", family: sa_family_t(AF_INET)),
            InterfaceType(name: "utun0", family: sa_family_t(AF_INET6))
        ]
        
        return ipStorage
            .filter { searchs.contains($0.key) }
            .map { key, value in
                IP(ip: value, interfaceType: key)
            }
    }
    
    private func fetchType() -> NetworkType {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .none
        }
        
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return .none
        }
        
        if !flags.contains(.reachable) {
            return .none
        }
        
        var type = NetworkType.none
        
        if !flags.contains(.connectionRequired) {
            type = .wifi
        }
        
        if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
            if !flags.contains(.interventionRequired) {
                type = .wifi
            }
        }
        
        #if os(iOS) || os(tvOS)
        if flags.contains(.isWWAN) {
            return .cellular
        }
        #endif
        
        return type
    }
}

extension NetworkFetcher {
    private enum NetworkType {
        case cellular
        case wifi
        case none
    }
}

#endif
