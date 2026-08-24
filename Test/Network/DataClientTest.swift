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
    
    func test__request() async {
        final class MockURLResultStorage: URLResultStorage {
            nonisolated(unsafe) static let results: [URLResult] = [
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
        
        Expect.promise(
            response,
            state: .resolved({
                $0 == (200, ["X-Response-ID": "success"], Data())
            }),
            timeout: .seconds(2)
        )
    }

    func test__request_without_data_returns_empty_data() async {
        final class MockURLResultStorage: URLResultStorage {
            nonisolated(unsafe) static let results: [URLResult] = [
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

        Expect.promise(
            response,
            state: .resolved({ $0 == (204, [:], Data()) }),
            timeout: .seconds(2)
        )
    }
    
    func test__request_reponse_code_not_2XX() async {
        final class MockURLResultStorage: URLResultStorage {
            nonisolated(unsafe) static let results: [URLResult] = [
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
    
    func test__request_error() async {
        final class MockURLResultStorage: URLResultStorage {
            nonisolated(unsafe) static let results: [URLResult] = [
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
    
    func test__request_timeout() async {
        final class MockURLResultStorage: URLResultStorage {
            nonisolated(unsafe) static let results: [URLResult] = [
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

    func test__concurrent_request() async {
        final class MockURLResultStorage: URLResultStorage {
            nonisolated(unsafe) static let results: [URLResult] = [
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
        let completed = DispatchGroup()

        (0..<100)
            .map { _ in client.request(URL(string: "https://mock.api.ab180.co/request")!) }
            .forEach { promise in
                completed.enter()
                promise.subscribe(
                    onResolved: { _ in completed.leave() },
                    onRejected: { _ in completed.leave() },
                    onCanceled: { completed.leave() }
                )
            }

        XCTAssertEqual(completed.wait(timeout: .now() + 5), .success)
    }

    func test__client_deinit_cancels_request() async {
        final class MockURLResultStorage: URLResultStorage {
            nonisolated(unsafe) static let results: [URLResult] = [
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
        let canceled = DispatchSemaphore(value: 0)
        let response = client!.request(URL(string: "https://mock.api.ab180.co/request")!)
        response.subscribe(
            onResolved: { _ in XCTFail("Expected cancellation") },
            onRejected: { _ in XCTFail("Expected cancellation") },
            onCanceled: { canceled.signal() }
        )

        client = nil

        XCTAssertEqual(canceled.wait(timeout: .now() + 2), .success)
        for _ in 0..<100 where tasks != nil {
            try? await Task.sleep(nanoseconds: 1_000_000)
        }
        XCTAssertNil(tasks)
    }
}
