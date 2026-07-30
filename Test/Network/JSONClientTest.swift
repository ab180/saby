//
//  JSONClientTest.swift
//  SabyNetworkTest
//
//  Created by WOF on 2022/08/16.
//

import XCTest
@testable import SabyNetwork

import SabyJSON
import SabyTestMock
import SabyTestExpect
import SabyConcurrency

final class JSONClientTest: XCTestCase {
    func test__init() {
        let client = JSONClient(cancelWhen: .deinit)
        let configuration = URLSessionConfiguration.default
        
        XCTAssertEqual(client.client.session.configuration, configuration)
    }
    
    func test__init_option_block() {
        let client = JSONClient(cancelWhen: .deinit) {
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
                    headers: ["X-Response-ID": "success"],
                    data: try! JSON.from([:]).datafy()
                )
            ]
        }
        let client = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .resolved({
                $0 == (200, ["X-Response-ID": "success"], [:])
            }),
            timeout: .seconds(2)
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
        let client = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .rejected(JSONClientError.responseDataIsNotDecodable(code: 200, body: Data())),
            timeout: .seconds(2)
        )
    }
    
    func test__request_reponse_code_not_2XX() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 500,
                    data: try? JSON.from([]).datafy()
                )
            ]
        }
        let client = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .rejected(JSONClientError.statusCodeNot2XX(codeNot2XX: 500, body: [])),
            timeout: .seconds(2)
        )
    }

    func test__request_response_code_204_with_empty_body() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 204,
                    headers: ["X-Response-ID": "success"],
                    data: Data()
                )
            ]
        }
        let client = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }

        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )

        Expect.promise(
            response,
            state: .resolved({
                $0 == (204, ["X-Response-ID": "success"], [:])
            }),
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
        let client = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!,
            body: nil
        )
        
        Expect.promise(
            response,
            state: .rejected(Expect.SampleError.one),
            timeout: .seconds(2)
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
        let client = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!
        )
        
        Expect.promise(
            response,
            state: .rejected(JSONClientError.responseDataIsNotDecodable(code: 200, body: nil)),
            timeout: .seconds(2)
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
        let client = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(
            URL(string: "https://mock.api.ab180.co/request")!
        )
        
        Expect.promise(
            response,
            state: .rejected(JSONClientError.responseDataIsNotDecodable(code: 200, body: Data())),
            timeout: .seconds(2)
        )
    }
    
    func test__request_timeout() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: Promise.delay(.milliseconds(2000)).then { try! JSON.from([:]).datafy() }
                )
            ]
        }
        let client = JSONClient(cancelWhen: .deinit) {
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
        
        Expect.promise(response, state: .rejected(JSONClientError.timeout), timeout: .seconds(2))
    }
}
