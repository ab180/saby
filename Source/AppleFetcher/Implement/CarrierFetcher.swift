//
//  CarrierFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/24.
//

#if os(iOS) && canImport(CoreTelephony)

import Foundation
import CoreTelephony

public final class CarrierFetcher: Fetcher {
    public typealias Value = Carrier?
    
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

        return information
            .serviceSubscriberCellularProviders?
            .values
            .first { $0.carrierName != nil }
    }
}
   
#endif
