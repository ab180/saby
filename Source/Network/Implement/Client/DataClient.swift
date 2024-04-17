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
                pending.reject(error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                pending.reject(DataClientError.statusCodeNotFound)
                return
            }
            
            let code = response.statusCode
            guard code / 100 == 2 else {
                pending.reject(DataClientError.statusCodeNot2XX(codeNot2XX: code, body: data))
                return
            }

            pending.resolve((code2XX: code, body: data))
        }
        pending.onCancel {
            task.cancel()
        }
        if let timeout {
            let item = DispatchWorkItem { [weak task, weak pending] in
                task?.cancel()
                pending?.reject(DataClientError.timeout)
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
        
        storage[ObjectIdentifier(pending)] = pending
        let remove = { [weak self, weak pending] in
            guard let self, let pending else { return }
            self.storage[ObjectIdentifier(pending)] = nil
        }
        pending.promise.subscribe(
            onResolved: { _ in remove() },
            onRejected: { _ in remove() },
            onCanceled: { remove() }
        )
        
        return pending.promise
    }
}

public enum DataClientError: Error {
    case timeout
    case statusCodeNotFound
    case statusCodeNot2XX(codeNot2XX: Int, body: Data?)
}
