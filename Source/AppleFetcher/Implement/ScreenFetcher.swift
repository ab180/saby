//
//  ScreenFetcher.swift
//  SabyAppleFetcher
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

import SabyConcurrency

public final class ScreenFetcher: Fetcher {
    public typealias Value = Promise<Screen, Error>
    
    public init() {}

    public func fetch() -> Promise<Screen, Error> {
        return Promise.all(
            Promise<CGSize, Error>.resolved(fetchSize()),
            Promise<CGFloat, Error>.resolved(fetchScale()),
            fetchOrientation()
        )
        .then { size, scale, orientation in
            Screen(
                width: size.width,
                height: size.height,
                scale: scale,
                orientation: orientation.isLandscape ? "landscape": "portrait"
            )
        }
    }
}

public struct Screen {
    public let width: Double
    public let height: Double
    public let scale: Double
    public let orientation: String
}

extension ScreenFetcher {
    private func fetchSize() -> CGSize {
        return UIScreen.main.bounds.size
    }

    private func fetchScale() -> CGFloat {
        UIScreen.main.scale
    }
    
    private func fetchOrientation() -> Promise<UIInterfaceOrientation, Error> {
        Promise.async(on: .main) { () -> UIInterfaceOrientation in
            if #available(iOS 13.0, macCatalyst 13.0, tvOS 13.0, *) {
                return UIApplication.shared.connectedScenes
                    .deepFilter { $0.activationState == .foregroundActive }
                    .first { $0 is UIWindowScene }
                    .flatMap { $0 as? UIWindowScene }?
                    .interfaceOrientation ?? .portrait
            }
            else {
                return UIApplication.shared.statusBarOrientation
            }
        }
    }
}

#endif
