//
//  ManagementService.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/11/24.
//

import Hermes
import Foundation

/// This service is in charge of handling requests that the user may want to create that has to do with bug reporting, reporting bad actors and giving feedback.
class ManagementService {
    
    private var http: Courrier
    private let tokenStore: SecureStore
    
    init() {
        var host: String
        
#if DEBUG
            host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        #else
            host = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
        #endif
        
        self.tokenStore = SecureStore()
        self.http = Courrier(.HTTPS, host: host)
    }
    
    /// HTTP request to create a bug report
    ///
    /// The dao object is the data needed to create the report
    ///
    /// - Returns: the http body and headers
    func createBugReport(dao: BugReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/bugs")
        return try await http.Request(.POST, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }

    /// HTTP request to get bug reports
    /// 
    /// Filter through reports by the uuid of the user who created the request.
    ///
    /// - Returns: the http body and the headers
    func getBugReports(uuid: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/bugs", queryItems: [URLQueryItem(name: "uuid", value: uuid)])
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to create a field report
    ///
    /// The dao object is the data needed to create the report
    ///
    /// - Returns: the http body and headers
    func createFieldReport(dao: FieldReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/fields")
        return try await http.Request(.POST, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to get field reports
    ///
    /// Filter through reports by the uuid of the user who created the request.
    ///
    /// - Returns: the http body and headers
    func getFieldReports(uuid: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/fields", queryItems: [URLQueryItem(name: "uuid", value: uuid)])
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to create an event report
    ///
    /// The dao object is the data needed to create the report
    ///
    /// - Returns: the http body and headers
    func createEventReport(dao: EventReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/events")
        return try await http.Request(.POST, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to get event reports
    ///
    /// Filter through reports by the id of the group and the status of the reports
    ///
    /// - Returns: the http body and the headers
    func getEventReports(id: String, status: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/events", queryItems: [URLQueryItem(name: "groupID", value: id), URLQueryItem(name: "status", value: status)])
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to update an event report
    ///
    /// The dao object is the data needed to update the report
    ///
    /// - Returns: the http body and headers
    func updateEventReport(id: String, dao: EventReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/events/\(id)")
        return try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to create a post report
    ///
    /// The dao object is the data needed to create the report
    ///
    /// - Returns: the http body and headers
    func createPostReport(dao: PostReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/posts")
        return try await http.Request(.POST, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to get post reports
    ///
    /// Filter through reports by the id of the group and the status of the reports
    ///
    /// - Returns: the http body and the headers
    func getPostReports(id: String, status: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/posts", queryItems: [URLQueryItem(name: "groupID", value: id), URLQueryItem(name: "status", value: status)])
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to update a post report
    ///
    /// The dao object is the data needed to update the report
    ///
    /// - Returns: the http body and headers
    func updatePostReport(id: String, dao: PostReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/posts/\(id)")
        return try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to create a member report
    ///
    /// The dao object is the data needed to create the report
    ///
    /// - Returns: the http body and headers
    func createMemberReport(dao: MemberReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/members")
        return try await http.Request(.POST, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to get member reports
    ///
    /// Filter through reports by the id of the group and the status of the reports
    ///
    /// - Returns: the http body and the headers
    func getMemberReports(id: String, status: String) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/members", queryItems: [URLQueryItem(name: "groupID", value: id), URLQueryItem(name: "status", value: status)])
        return try await http.Request(.GET, endpoint, headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
    
    /// HTTP request to update a member report
    ///
    /// The dao object is the data needed to update the report
    ///
    /// - Returns: the http body and headers
    func updateMemberReport(id: String, dao: MemberReportDao) async throws -> (Data, URLResponse) {
        let endpoint = Endpoint("/report/members/\(id)")
        return try await http.Request(.PUT, endpoint, body: EncodeToData(dao), headers: ["Authorization": tokenStore.fetchTokenFromKeyChain()])
    }
}
