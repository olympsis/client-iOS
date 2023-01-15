//
//  FriendRequests.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import SwiftUI
/*
struct FriendRequestsView: View {
    @State private var requests = [FriendRequest]()
    @State private var status: LOADING_STATE = .loading
    
    @StateObject private var userObserver = UserObserver()
    var body: some View {
        ScrollView(showsIndicators: false){
            if status == .loading {
                ProgressView()
                    .padding(.top)
            } else if status == .success {
                if requests.isEmpty {
                    Text("No Friend Requests")
                        .padding(.top)
                } else {
                    ForEach(requests) { request in
                        FriendRequestView(request: request, observer: userObserver, requests: $requests)
                    }
                }
            } else if status == .failure {
                Text("Failed to get requests")
                    .padding(.top)
            }
        }.task {
            do {
                let res = try await userObserver.GetFriendRequests()
                await MainActor.run {
                    if let res = res {
                        requests = res
                        status = .success
                    }
                }
            } catch {
                status = .failure
                print(error)
            }
        }
        
    }
}

struct FriendRequests_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestsView()
    }
}
*/
