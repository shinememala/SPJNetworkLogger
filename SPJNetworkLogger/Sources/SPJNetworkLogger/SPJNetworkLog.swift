//
//  SPJNetworkLog.swift
//  POC
//
//  Created by Shine PJ on 15/07/2024.
//

import Foundation

class SPJNetworkLog: Codable {
    var url: String
    var method: String
    var requestHeaders: String
    var requestBody: Data?
    var statusCode: Int
    var responseHeaders: String
    var responseBody: Data?
    var timestamp: Date
    var responseTime: TimeInterval

    init(url: String, method: String, requestHeaders: String, requestBody: Data?, statusCode: Int, responseHeaders: String, responseBody: Data?, timestamp: Date, responseTime: TimeInterval) {
        self.url = url
        self.method = method
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.statusCode = statusCode
        self.responseHeaders = responseHeaders
        self.responseBody = responseBody
        self.timestamp = timestamp
        self.responseTime = responseTime
    }
}
