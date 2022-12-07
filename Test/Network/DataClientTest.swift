//
//  DataClientTest.swift
//  SabyNetworkTest
//
//  Created by WOF on 2022/08/10.
//

import XCTest
@testable import SabyNetwork

import SabyMock
import SabyExpect

final class DataClientTest: XCTestCase {
    func test__init() {
        let client = DataClient()
        let configuration = URLSessionConfiguration.default
        
        XCTAssertEqual(client.session.configuration, configuration)
    }
    
    func test__init_option_block() {
        let client = DataClient() {
            $0.timeoutIntervalForRequest = 3000
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3000
        
        XCTAssertEqual(client.session.configuration, configuration)
    }
    
    func test__request() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: Data()
                )
            ]
        }
        let client = DataClient() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        Expect.promise(response, state: .resolved(Data()), timeout: .seconds(2))
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
        let client = DataClient() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        Expect.promise(response, state: .rejected(DataClient.InternalError.responseCodeNot2XX), timeout: .seconds(2))
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
        let client = DataClient() {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        Expect.promise(response, state: .rejected(Expect.SampleError.one), timeout: .seconds(2))
    }
}
