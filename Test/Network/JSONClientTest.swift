//
//  JSONClientTest.swift
//  SabyNetworkTest
//
//  Created by WOF on 2022/08/16.
//

import Foundation
import Testing
@testable import SabyNetwork

import SabyJSON
import SabyConcurrency

@Suite(.serialized) struct JSONClientTest {
    @Test func test__init() {
        let client = JSONClient(cancelWhen: .deinit)
        let configuration = URLSessionConfiguration.default
        
        #expect(client.client.session.configuration == configuration)
    }
    
    @Test func test__init_option_block() {
        let client = JSONClient(cancelWhen: .deinit) {
            $0.timeoutIntervalForRequest = 3000
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3000
        
        #expect(client.client.session.configuration == configuration)
    }
    
    @Test func test__request() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectResolved(response) {
            $0 == (200, ["X-Response-ID": "success"], [:])
        }
    }
    
    @Test func test__request_reponse_code_not_decodable() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectRejected(
            response,
            error: JSONClientError.responseDataIsNotDecodable(code: 200, body: Data())
        )
    }
    
    @Test func test__request_reponse_code_not_2XX() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectRejected(
            response,
            error: JSONClientError.statusCodeNot2XX(codeNot2XX: 500, body: [])
        )
    }
    
    @Test func test__request_error() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    error: NetworkTestError.sample
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
        
        await expectRejected(response, error: NetworkTestError.sample)
    }
    
    @Test func test__request_response_nil() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectRejected(
            response,
            error: JSONClientError.responseDataIsNotDecodable(code: 200, body: nil)
        )
    }
    
    @Test func test__request_response_empty() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectRejected(
            response,
            error: JSONClientError.responseDataIsNotDecodable(code: 200, body: Data())
        )
    }
    
    @Test func test__request_timeout() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectRejected(response, error: JSONClientError.timeout)
    }

    @Test func test__client_deinit_cancels_request() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: Promise.delay(.seconds(2)).then { try! JSON.from([:]).datafy() }
                )
            ]
        }
        var client: JSONClient? = JSONClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        weak let tasks = client?.tasks
        let response = client!.request(URL(string: "https://mock.api.ab180.co/request")!)

        client = nil

        await expectCanceled(response)
        #expect(await eventually { tasks == nil })
    }
}
