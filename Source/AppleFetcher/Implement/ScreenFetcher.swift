//
//  ScreenFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/23.
//

#if (os(iOS) || os(tvOS)) && canImport(UIKit)

import Foundation
import UIKit

import SabyConcurrency

public final class ScreenFetcher: Fetcher {
    public typealias Value = Promise<Screen, Error>
    
    public init() {}
    
    public func fetch() -> Promise<Screen, Error> {
        Promise.async { () async throws -> Screen in
            await MainActor.run {
                let screen = UIScreen.main

                #if os(iOS)
                let orientation = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first { $0.activationState == .foregroundActive }?
                    .interfaceOrientation ?? .portrait
                let orientationName = orientation.isLandscape ? "landscape" : "portrait"
                #else
                let orientationName = "landscape"
                #endif

                return Screen(
                    width: screen.bounds.width,
                    height: screen.bounds.height,
                    scale: screen.scale,
                    orientation: orientationName
                )
            }
        }
    }
}

public struct Screen: Sendable {
    public let width: Double
    public let height: Double
    public let scale: Double
    public let orientation: String
}

#endif
