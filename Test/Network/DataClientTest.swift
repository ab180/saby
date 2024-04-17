//
//  DataClientTest.swift
//  SabyNetworkTest
//
//  Created by WOF on 2022/08/10.
//

import XCTest
@testable import SabyNetwork

import SabyTestMock
import SabyTestExpect
import SabyConcurrency

final class DataClientTest: XCTestCase {
    func test__init() {
        let client = DataClient(cancelWhen: .deinit)
        let configuration = URLSessionConfiguration.default
        
        XCTAssertEqual(client.session.configuration, configuration)
    }
    
    func test__init_option_block() {
        let client = DataClient(cancelWhen: .deinit) {
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
        let client = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        Expect.promise(response, state: .resolved({ $0 == (200, Data()) }), timeout: .seconds(2))
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
        let client = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        Expect.promise(
            response,
            state: .rejected(DataClientError.statusCodeNot2XX(codeNot2XX: 200, body: Data())),
            timeout: .seconds(2)
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
        let client = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        Expect.promise(response, state: .rejected(Expect.SampleError.one), timeout: .seconds(2))
    }
    
    func test__request_timeout() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: Promise.delay(.milliseconds(2000)).then { Data() }
                )
            ]
        }
        let client = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            timeout: .millisecond(50)
        )
        
        response.then { data in
            print(data)
        }
        .catch { error in
            print(error)
        }
        
        Expect.promise(response, state: .rejected(DataClientError.timeout), timeout: .seconds(2))
    }
}
