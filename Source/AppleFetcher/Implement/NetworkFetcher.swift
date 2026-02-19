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
            ipList: ipList,
            isCellular: type == .cellular,
            isWiFi: type == .wifi
        )
    }
}

public struct IP {
    public let address: String
    public let interface: String
    public let version: IP.Version
}

extension IP {
    public enum Version {
        case v4
        case v6
    }
}

public struct Network {
    public let ipList: [IP]
    public let isCellular: Bool
    public let isWiFi: Bool
}

extension NetworkFetcher {
    private func fetchIPList() -> [IP] {
        var ipList: [IP] = []
        
        var interfacesPointer: UnsafeMutablePointer<ifaddrs>?
        defer { freeifaddrs(interfacesPointer) }
        guard getifaddrs(&interfacesPointer) == 0 else { return [] }
        guard let interfaceFirstPointer = interfacesPointer else { return [] }
        
        for interfacePointer in sequence(
            first: interfaceFirstPointer,
            next: { $0.pointee.ifa_next }
        ) {
            let interface = interfacePointer.pointee
            
            guard interface.ifa_addr != nil else { continue }
            
            let family = interface.ifa_addr.pointee.sa_family
            guard let protocolVersion = {
                switch Int32(family) {
                case AF_INET:
                    return IP.Version.v4
                case AF_INET6:
                    return IP.Version.v6
                default:
                    return nil
                }
            }()
            else { continue }
            
            let interfaceName = String(cString: interface.ifa_name)
            guard ["en0", "pdp_ip0", "utun0"].contains(interfaceName) else { continue }
            
            let ip = { () -> String? in
                var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let result = getnameinfo(
                    interface.ifa_addr,
                    socklen_t(interface.ifa_addr.pointee.sa_len),
                    &buffer,
                    socklen_t(buffer.count),
                    nil,
                    socklen_t(0),
                    NI_NUMERICHOST
                )
                
                guard result == 0 else { return nil }
                
                return String(cString: buffer)
            }()
            
            guard let ip else { continue }
            
            ipList.append(IP(address: ip, interface: interfaceName, version: protocolVersion))
        }
        
        return ipList
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
