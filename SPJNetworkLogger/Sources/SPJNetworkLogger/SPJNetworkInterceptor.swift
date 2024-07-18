//
//  SPJNetworkInterceptor.swift
//  POC
//
//  Created by Shine PJ on 15/07/2024.
//

import Foundation

public class SPJNetworkInterceptor: URLProtocol {
    static var ignoredHosts = [String]()

    struct Constants {
        static let RequestHandledKey = "URLProtocolRequestHandled"
    }
    
    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    var currentRequest: SPJNetworkLog?
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    override public class func canInit(with request: URLRequest) -> Bool {
        guard SPJNetworkInterceptor.shouldHandleRequest(request) else { return false }

        if SPJNetworkInterceptor.property(forKey: Constants.RequestHandledKey, in: request) != nil {
            return false
        }
        print("Intercepting request: \(request.url?.absoluteString ?? "")")
        return true
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public func startLoading() {
        guard let newRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "SPJNetworkInterceptorErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to copy request"]))
            return
        }

        SPJNetworkInterceptor.setProperty(true, forKey: Constants.RequestHandledKey, in: newRequest)
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
        
        currentRequest = createLog(from: newRequest as URLRequest)
        SPJNetworkLogger.shared.addLog(currentRequest!)
    }
    
    override public func stopLoading() {
        sessionTask?.cancel()
        updateRequestBody()
        updateResponseTime()
    }
    
    private func updateRequestBody() {
        currentRequest?.requestBody = body(from: request)
    }

    private func updateResponseTime() {
        if let startDate = currentRequest?.timestamp {
            currentRequest?.responseTime = fabs(startDate.timeIntervalSinceNow) * 1000 // Find elapsed time and convert to milliseconds
        }
    }

    private func body(from request: URLRequest) -> Data? {
        return request.httpBody ?? request.httpBodyStream?.readfully()
    }

    private class func shouldHandleRequest(_ request: URLRequest) -> Bool {
        guard let host = request.url?.host else { return false }
        return SPJNetworkInterceptor.ignoredHosts.filter({ host.hasSuffix($0) }).isEmpty
    }
    
    private func createLog(from request: URLRequest) -> SPJNetworkLog {
        let log = SPJNetworkLog(
            url: request.url?.absoluteString ?? "",
            method: request.httpMethod ?? "",
            requestHeaders: request.allHTTPHeaderFields?.description ?? "",
            requestBody: request.httpBody,
            statusCode: 0,
            responseHeaders: "",
            responseBody: nil,
            timestamp: Date(),
            responseTime: 0
        )
        print("Log created for request: \(log.url)")
        return log
    }
}

extension SPJNetworkInterceptor: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        if currentRequest?.responseBody == nil {
            currentRequest?.responseBody = data
        } else {
            currentRequest?.responseBody?.append(data)
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        if let httpResponse = response as? HTTPURLResponse {
            currentRequest?.statusCode = httpResponse.statusCode
            currentRequest?.responseHeaders = httpResponse.allHeaderFields.description
        }
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            currentRequest?.responseHeaders = error.localizedDescription
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        currentRequest?.responseHeaders = error.localizedDescription
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
