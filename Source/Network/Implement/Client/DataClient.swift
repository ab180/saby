//
//  DataClient.swift
//  SabyRequest
//
//  Created by WOF on 2022/08/09.
//

import Foundation

import SabyConcurrency
import SabyJSON

public final class DataClient: Client {
    public typealias Request = Data?
    public typealias Response = Data?
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
}

extension DataClient {
    public convenience init(optionBlock: (inout URLSessionConfiguration) -> Void = { _ in }) {
        var configuration = URLSessionConfiguration.default
        optionBlock(&configuration)
    
        let session = URLSession(configuration: configuration)
        self.init(session: session)
    }
}

extension DataClient {
    public func request(
        url: URL,
        method: ClientMethod = .get,
        header: ClientHeader = [:],
        body: Data? = nil,
        optionBlock: (inout URLRequest) -> Void = { _ in }
    ) -> Promise<Data?, Error> {
        let pending = Promise<Data?, Error>.pending()
        
        var request = URLRequest(url: url)
        optionBlock(&request)

        request.url = url
        request.httpMethod = method.rawValue
        header.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                pending.reject(error)
                return
            }
            
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode / 100 == 2
            else {
                pending.reject(InternalError.responseCodeNot2XX)
                return
            }

            pending.resolve(data)
        }
        pending.onCancel {
            task.cancel()
        }
        task.resume()
        
        return pending.promise
    }
}

extension DataClient {
    public enum InternalError: Error {
        case responseCodeNot2XX
    }
}
