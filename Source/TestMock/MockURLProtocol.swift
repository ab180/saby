//
//  MockURLProtocol.swift
//  SabyTest
//
//  Created by WOF on 2022/08/11.
//

import Foundation

import SabyJSON

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

        if let data = result.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let error = result.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        else {
            client?.urlProtocolDidFinishLoading(self)
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
    let data: Data?
    let error: Error?
    
    public init(url: URL, code: Int, data: Data?) {
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)
        
        self.url = url
        self.response = response
        self.data = data
        self.error = nil
    }
    
    public init(url: URL, code: Int, json: JSON) {
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)
        let (data, error) = { () -> (Data?, Error?) in
            do {
                return (try json.datafy(), nil)
            }
            catch {
                return (nil, error)
            }
        }()
        
        self.url = url
        self.response = response
        self.data = data
        self.error = error
    }
    
    public init(url: URL, error: Error) {
        self.url = url
        self.response = nil
        self.data = nil
        self.error = error
    }
}
