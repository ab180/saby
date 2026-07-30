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
    func test__error_headers() {
        let headers = ["X-Response-ID": "failure"]
        let errors: [ClientError] = [
            DataClientError.requestFailed(error: Expect.SampleError.one, headers: headers),
            DataClientError.timeout(headers: headers),
            DataClientError.statusCodeNotFound(headers: headers),
            DataClientError.statusCodeNot2XX(
                codeNot2XX: 500,
                headers: headers,
                body: nil
            ),
        ]

        errors.forEach {
            XCTAssertEqual($0.headers, headers)
        }
    }

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
    
    func test__request_reponse_code_not_2XX() {
        final class MockURLResultStorage: URLResultStorage {
            static var results: [URLResult] = [
                URLResult(
                    url: URL(string: "https://mock.api.ab180.co/request")!,
                    code: 500,
                    headers: ["X-Response-ID": "failure"],
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
            state: .rejected(DataClientError.statusCodeNot2XX(
                codeNot2XX: 500,
                headers: ["X-Response-ID": "failure"],
                body: Data()
            )),
            timeout: .seconds(2)
        )
        assertHeaders(
            response,
            expected: ["X-Response-ID": "failure"]
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
        
        Expect.promise(
            response,
            state: .rejected(DataClientError.requestFailed(
                error: Expect.SampleError.one,
                headers: nil
            )),
            timeout: .seconds(2)
        )
        assertHeaders(response, expected: nil)
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
        
        Expect.promise(
            response,
            state: .rejected(DataClientError.timeout(headers: nil)),
            timeout: .seconds(2)
        )
        assertHeaders(response, expected: nil)
    }

    private func assertHeaders(
        _ response: Promise<ClientResult<Data?>, Error>,
        expected: ClientHeader?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let end = expectation(description: "Wait for rejected response")
        response.catch { error in
            guard let error = error as? ClientError else {
                XCTFail("Expected ClientError", file: file, line: line)
                end.fulfill()
                return
            }
            XCTAssertEqual(error.headers, expected, file: file, line: line)
            end.fulfill()
        }
        wait(for: [end], timeout: 2)
    }
}
