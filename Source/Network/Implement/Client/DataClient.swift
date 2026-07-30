//
//  DataClient.swift
//  SabyRequest
//
//  Created by WOF on 2022/08/09.
//

import Foundation

import SabyConcurrency
import SabyJSON
import SabyTime

public final class DataClient: Client {
    public typealias Request = Data?
    public typealias Response = Data?
    
    let lock = Lock()
    var storage = [ObjectIdentifier: PromisePending<ClientResult<Data?>, Error>]()
    
    let session: URLSession
    let cancelWhen: PromisePendingCancelWhen
    
    init(
        session: URLSession,
        cancelWhen: PromisePendingCancelWhen
    ) {
        self.session = session
        self.cancelWhen = cancelWhen
    }
}

extension DataClient {
    public convenience init(
        cancelWhen: PromisePendingCancelWhen,
        optionBlock: (inout URLSessionConfiguration) -> Void = { _ in }
    ) {
        var configuration = URLSessionConfiguration.default
        optionBlock(&configuration)
    
        let session = URLSession(configuration: configuration)
        self.init(
            session: session,
            cancelWhen: cancelWhen
        )
    }
}

extension DataClient {
    public func request(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: Data? = nil,
        timeout: Interval? = nil,
        optionBlock: @escaping (inout URLRequest) -> Void = { _ in }
    ) -> Promise<ClientResult<Data?>, Error> {
        let pending = Promise<ClientResult<Data?>, Error>.pending(cancelWhen: cancelWhen)
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        header.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        optionBlock(&request)
        
        let task = session.dataTask(with: request) { [weak pending] data, response, error in
            guard let pending else { return }
            
            if let error = error {
                pending.reject(DataClientError.requestFailed(
                    error: error,
                    headers: (response as? HTTPURLResponse)?.headers
                ))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                pending.reject(DataClientError.statusCodeNotFound(headers: nil))
                return
            }
            
            let code = response.statusCode
            guard code / 100 == 2 else {
                pending.reject(DataClientError.statusCodeNot2XX(
                    codeNot2XX: code,
                    headers: response.headers,
                    body: data
                ))
                return
            }

            pending.resolve((
                code2XX: code,
                headers: response.headers,
                body: data
            ))
        }
        pending.onCancel {
            task.cancel()
        }
        if let timeout {
            let item = DispatchWorkItem { [weak task, weak pending] in
                task?.cancel()
                pending?.reject(DataClientError.timeout(headers: nil))
            }
            DispatchQueue.global().asyncAfter(
                deadline: .now() + timeout.dispatchTime,
                execute: item
            )
            pending.promise.finally {
                item.cancel()
            }
            pending.onCancel {
                item.cancel()
            }
        }
        
        task.resume()
        
        lock.lock()
        storage[ObjectIdentifier(pending)] = pending
        lock.unlock()
        let remove = { [weak self, weak pending] in
            guard let self, let pending else { return }
            self.lock.lock()
            self.storage.removeValue(forKey: ObjectIdentifier(pending))
            self.lock.unlock()
        }
        pending.promise.subscribe(
            onResolved: { _ in remove() },
            onRejected: { _ in remove() },
            onCanceled: { remove() }
        )
        
        return pending.promise
    }
}

public enum DataClientError: ClientError {
    case requestFailed(error: Error, headers: ClientHeader?)
    case timeout(headers: ClientHeader?)
    case statusCodeNotFound(headers: ClientHeader?)
    case statusCodeNot2XX(codeNot2XX: Int, headers: ClientHeader?, body: Data?)

    public var headers: ClientHeader? {
        switch self {
        case .requestFailed(_, let headers):
            return headers
        case .timeout(let headers):
            return headers
        case .statusCodeNotFound(let headers):
            return headers
        case .statusCodeNot2XX(_, let headers, _):
            return headers
        }
    }
}

private extension HTTPURLResponse {
    var headers: ClientHeader {
        allHeaderFields.reduce(into: [:]) { headers, field in
            guard let key = field.key as? String else { return }
            headers[key] = String(describing: field.value)
        }
    }
}
