//
//  CarrierFetcher.swift
//  SabyAppleDataFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS)

import Foundation
import CoreTelephony

public final class CarrierFetcher: Fetcher {
    typealias Value = Carrier?
    
    public init() {}
    
    public func fetch() -> Carrier? {
        guard let carrier = fetchCTCarrier() else { return nil }
        
        return Carrier(
            name: carrier.carrierName,
            mobileNetworkCode: carrier.mobileNetworkCode,
            mobileCountryCode: carrier.mobileCountryCode
        )
    }
}

public struct Carrier {
    public let name: String?
    public let mobileNetworkCode: String?
    public let mobileCountryCode: String?
}

extension CarrierFetcher {
    private func fetchCTCarrier() -> CTCarrier? {
        let information = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            return information
                .serviceSubscriberCellularProviders?
                .values
                .first { $0.carrierName != nil }
        } else {
            return information.subscriberCellularProvider
        }
    }
}
   
#endif
