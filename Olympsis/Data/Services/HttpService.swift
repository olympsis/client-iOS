//
//  HttpService.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI
import Foundation


enum Method {
    case GET
    case POST
    case PUT
    case DELETE
}

enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case encodingError(Error)
    case unableToMakeRequest(Error)
    case invalidURL
}

extension NetworkError: LocalizedError {
    var errorstring: String? {
        switch self {
        case .unableToMakeRequest:
            return NSLocalizedString("Unable to make request", comment: "")
        default:
            return NSLocalizedString("Unexpected Error", comment: "")
        }
    }
}

class HttpService: ObservableObject {
    
    private var token:String
    private let logger:Logger
    private let host:String
    private var cacheService: CacheService
   
    init() {
        logger = Logger()
        host = Bundle.main.object(forInfoDictionaryKey: "HOST") as! String
        cacheService = CacheService()
        token = cacheService.fetchToken()
    }
    
    func fetchToken() {
        token = cacheService.fetchToken()
    }
    
    func setToken(t: String) {
        token = t
    }
    
    /// Creates an HTTP request
    /// - Parameter endpoint:`Endpoint` path values and query parameters
    /// - Parameter method: `Method` http method enum type
    /// - Parameter body: `Dao` body of the the request, a Dao Object
    /// - Note: i need to add better error handling
    func Request(endpoint: Endpoint, method:Method, body:Dao? = nil) async throws -> (Data, URLResponse) {
        
        // create session, url and request
        let session = URLSession.shared
        
        // encode request
        let encodedRequest = try JSONEncoder().encode(body)
        
        // construct request url
        var urlComp = URLComponents()
        urlComp.scheme = "https"
        urlComp.host = host
        urlComp.path = endpoint.path
        urlComp.queryItems = endpoint.queryItems
        
        // create url
        guard let url = urlComp.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        do {
            if (method == Method.GET) {
                request.httpMethod = "GET"
            } else if (method == Method.POST) {
                request.httpMethod = "POST"
                request.httpBody = encodedRequest
            } else if (method == Method.PUT) {
                request.httpMethod = "PUT"
                request.httpBody = encodedRequest
            } else if (method == Method.DELETE) {
                request.httpMethod = "DELETE"
            }
            
            // request parameters
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("olympsis-ios", forHTTPHeaderField: "User-Agent")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Connection", forHTTPHeaderField: "keep-alive")
            
            // log request
            logger.log("Making a \(request.httpMethod!) request to \(url)")

            // grab and decode data
            let (data, response) = try await session.data(for: request)
            /*guard (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201 || (response as? HTTPURLResponse)?.statusCode == 404 else { fatalError("Error while fetching data") }*/
            
            return (data, response)
        } catch {
            logger.error("\(error.localizedDescription)")
            throw NetworkError.unableToMakeRequest(error)
        }
    }
    
    /// Creates an HTTP request, to upload an object
    /// - Parameter endpoint:`Endpoint` path values and query parameters
    /// - Parameter method: `Method` http method enum type
    /// - Parameter body: `Dao` body of the the request, a Dao Object
    /// - Note: i need to add better error handling
    func UploadImage(url: String, body:Data? = nil) async throws -> (Data, URLResponse) {
        
        // create session, url and request
        let session = URLSession.shared
        
        let url = URL(string: url)!
        
        var request = URLRequest(url: url)
        
        do {
  
            request.httpMethod = "PUT"
            request.httpBody = body
            
            // request parameters
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.setValue("*/*", forHTTPHeaderField: "Accept")
            request.setValue("Connection", forHTTPHeaderField: "keep-alive")
            
            // log request
            logger.log("Making a \(request.httpMethod!) request to \(url)")

            // grab and decode data
            let (data, response) = try await session.data(for: request)
            /*guard (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201 || (response as? HTTPURLResponse)?.statusCode == 404 else { fatalError("Error while fetching data") }*/
            
            return (data, response)
        } catch {
            logger.error("\(error.localizedDescription)")
            throw NetworkError.unableToMakeRequest(error)
        }
    }
}

