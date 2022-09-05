//
//  JSONClientTest.swift
//  SabyNetworkTest
//
//  Created by WOF on 2022/08/16.
//

import XCTest
@testable import SabyNetwork

import SabyJSON
import SabyMock
import SabyExpect

final class JSONClientTest: XCTestCase {
    func test__init() {
        let client = JSONClient<JSON, JSON>()
        let configuration = URLSessionConfiguration.default
        
        XCTAssertEqual(client.client.session.configuration, configuration)
    }
    
    func test__init_option_block() {
        let client = JSONClient<JSON, JSON>() {
            $0.timeoutIntervalForRequest = 3000
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3000
        
        XCTAssertEqual(client.client.session.configuration, configuration)
    }
    
    func test__request() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: try! JSON.from([:]).datafy()
                )
            ]
        }
        let client = JSONClient<JSON?, JSON>() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .resolved([:]),
            timeout: .seconds(1)
        )
    }
    
    func test__request_reponse_code_not_decodable() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: Data()
                )
            ]
        }
        let client = JSONClient<JSON?, JSON>() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .rejected(JSONClient<JSON?, JSON>.InternalError.responseDataIsNotDecodable),
            timeout: .seconds(1)
        )
    }
    
    func test__request_reponse_code_not_2XX() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 500,
                    data: Data()
                )
            ]
        }
        let client = JSONClient<JSON?, JSON>() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .rejected(DataClient.InternalError.responseCodeNot2XX),
            timeout: .seconds(1)
        )
    }
    
    func test__request_error() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    error: Expect.SampleError.one
                )
            ]
        }
        let client = JSONClient<JSON?, JSON>() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .rejected(Expect.SampleError.one),
            timeout: .seconds(1)
        )
    }
    
    func test__request_response_nil() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: nil
                )
            ]
        }
        let client = JSONClient<JSON?, Data?>() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!
        )
        
        Expect.promise(
            response,
            state: .resolved(Data()),
            timeout: .seconds(1)
        )
    }
    
    func test__request_response_empty() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: Data()
                )
            ]
        }
        let client = JSONClient<JSON?, Data>() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!
        )
        
        Expect.promise(
            response,
            state: .resolved(Data()),
            timeout: .seconds(1)
        )
    }
}
