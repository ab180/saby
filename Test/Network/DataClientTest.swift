//
//  DataClientTest.swift
//  SabyNetworkTest
//
//  Created by WOF on 2022/08/10.
//

import Foundation
import Testing
@testable import SabyNetwork

import SabyConcurrency

@Suite(.serialized) struct DataClientTest {
    @Test func test__init() {
        let client = DataClient(cancelWhen: .deinit)
        let configuration = URLSessionConfiguration.default
        
        #expect(client.session.configuration == configuration)
    }
    
    @Test func test__init_option_block() {
        let client = DataClient(cancelWhen: .deinit) {
            $0.timeoutIntervalForRequest = 3000
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3000
        
        #expect(client.session.configuration == configuration)
    }
    
    @Test func test__request() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    headers: ["X-Response-ID": "success"],
                    data: Data()
                )
            ]
        }
        let client = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        await expectResolved(response) {
            $0 == (200, ["X-Response-ID": "success"], Data())
        }
    }

    @Test func test__request_without_data_returns_empty_data() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 204,
                    data: nil
                )
            ]
        }
        let client = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }

        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)

        await expectResolved(response) { $0 == (204, [:], Data()) }
    }
    
    @Test func test__request_reponse_code_not_2XX() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectRejected(
            response,
            error: DataClientError.statusCodeNot2XX(codeNot2XX: 200, body: Data())
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
        let client = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        
        let response = client.request(URL(string: "https://mock.api.ab180.co/request")!)
        
        await expectRejected(response, error: NetworkTestError.sample)
    }
    
    @Test func test__request_timeout() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        
        await expectRejected(response, error: DataClientError.timeout)
    }

    @Test func test__concurrent_request() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
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
        let requests = (0..<100).map { _ in
            client.request(URL(string: "https://mock.api.ab180.co/request")!)
        }
        await withTaskGroup(of: Bool.self) { group in
            for request in requests {
                group.addTask {
                    do {
                        _ = try await request.value()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            for await completed in group {
                #expect(completed)
            }
        }
    }

    @Test func test__client_deinit_cancels_request() async {
        final class MockURLResultStorage: URLResultStorage {
            static let results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 200,
                    data: Promise.delay(.seconds(2)).then { Data() }
                )
            ]
        }
        var client: DataClient? = DataClient(cancelWhen: .deinit) {
            $0.protocolClasses = [MockURLProtocol<MockURLResultStorage>.self]
        }
        weak let tasks = client?.tasks
        let response = client!.request(URL(string: "https://mock.api.ab180.co/request")!)

        client = nil

        await expectCanceled(response)
        #expect(await eventually { tasks == nil })
    }
}
