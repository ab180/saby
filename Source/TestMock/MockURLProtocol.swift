//
//  MockURLProtocol.swift
//  SabyTest
//
//  Created by WOF on 2022/08/11.
//

import Foundation

import SabyJSON
import SabyConcurrency

public protocol URLResultStorage {
    static var results: [URLResult] { get }
}

public final class MockURLProtocol<Storage: URLResultStorage>: URLProtocol {
    public override class func canInit(with request: URLRequest) -> Bool {
        if
            let url = request.url,
            let _ = (Storage.results.first { $0.url == url })
        {
            return true
        }
        else {
            return false
        }
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    public override func startLoading() {
        guard
            let url = request.url,
            let result = (Storage.results.first { $0.url == url })
        else {
            client?.urlProtocol(self, didFailWithError: InternalError.noURLResult)
            return
        }

        if let response = result.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = result.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        result.data.then { data in
            guard let data else { return }
            self.client?.urlProtocol(self, didLoad: data)
        }
        .then {
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    public override func stopLoading() {}
}

extension MockURLProtocol {
    public enum InternalError: Error {
        case noURLResult
    }
}

public struct URLResult {
    let url: URL?
    let response: URLResponse?
    let data: Promise<Data?, Never>
    let error: Error?
    
    public init(url: URL, code: Int, data: Data?) {
        self.init(url: url, code: code, data: .resolved(data))
    }
    
    public init(url: URL, code: Int, data: Promise<Data?, Never>) {
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)
        
        self.url = url
        self.response = response
        self.data = data
        self.error = nil
    }
    
    public init(url: URL, code: Int, json: JSON) {
        self.init(url: url, code: code, json: .resolved(json))
    }
    
    public init(url: URL, code: Int, json: Promise<JSON, Never>) {
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)
        
        self.url = url
        self.response = response
        self.data = json.then { try? $0.datafy() }
        self.error = nil
    }
    
    public init(url: URL, error: Error) {
        self.url = url
        self.response = nil
        self.data = .resolved(nil)
        self.error = error
    }
}
