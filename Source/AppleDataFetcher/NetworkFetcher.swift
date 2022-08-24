//
//  NetworkFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation
import SystemConfiguration

import SabyConcurrency

public final class NetworkFetcher: Fetcher {
    typealias Value = Network

    func fetch() -> Network {
        let ip = fetchIP()
        let type = fetchType()
        
        return Network(
            ip: ip,
            isCellular: type == .cellular,
            isWiFi: type == .wifi
        )
    }
}

public struct Network {
    let ip: String?
    let isCellular: Bool
    let isWiFi: Bool
}

extension NetworkFetcher {
    private func fetchIP() -> String? {
        struct InterfaceType: Hashable {
            let name: String
            let family: sa_family_t
        }
        
        var ipStorage: [InterfaceType: String] = [:]
        
        var interfacesPointer: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfacesPointer) == 0 else { return nil }
        guard let interfaceFirstPointer = interfacesPointer else { return nil }
        
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
        
        let searchs = [
            InterfaceType(name: "en0", family: sa_family_t(AF_INET)),
            InterfaceType(name: "en0", family: sa_family_t(AF_INET6)),
            InterfaceType(name: "pdp_ip0", family: sa_family_t(AF_INET)),
            InterfaceType(name: "pdp_ip0", family: sa_family_t(AF_INET6)),
            InterfaceType(name: "utun0", family: sa_family_t(AF_INET)),
            InterfaceType(name: "utun0", family: sa_family_t(AF_INET6))
        ]
        
        for search in searchs {
            if let ip = ipStorage[search] {
                return ip
            }
        }
        
        return nil
    }
    
    private func fetchType() -> NetworkType {
        var zeroAddress = sockaddr()
        bzero(&zeroAddress, MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sa_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let reachability = SCNetworkReachabilityCreateWithAddress(
            kCFAllocatorDefault,
            &zeroAddress
        ) else {
            return .none
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return .none
        }
        
        if !flags.contains(.reachable) {
            return .none
        }
        
        if flags.contains(.connectionRequired)
            && !(
                (flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic))
                && !flags.contains(.interventionRequired)
            )
        {
            return .none
        }
        
        #if os(iOS) || os(tvOS)
        if flags.contains(.isWWAN) {
            return .cellular
        }
        #endif
        
        return .wifi
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
