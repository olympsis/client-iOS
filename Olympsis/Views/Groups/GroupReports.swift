//
//  GroupReports.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/20/24.
//

import os
import SwiftUI
import Hermes

struct GroupReports: View {
    
    @State private var selectedTab: Int = 0
    @State private var status: LOADING_STATE = .pending
    @State private var postReports: [PostReport] = []
    @State private var eventReports: [EventReport] = []
    @State private var memberReports: [MemberReport] = []
    @StateObject private var manager: ManagementObserver = ManagementObserver()
    @Environment(SessionStore.self) private var session
    @Environment(\.dismiss) private var dismiss
    
    private var logger: Logger = Logger(subsystem: "com.olympsis.client", category: "group_reports_view")
    
    func fetchNewReports() async {
        var groupID: String = ""
        guard let selectedGroup = session.groupsManager.selected else {
            return
        }
        if selectedGroup.club != nil {
            groupID = selectedGroup.club?.id ?? ""
        } else {
            groupID = selectedGroup.organization?.id ?? ""
        }
        do {
            status = .loading
            if let pr = try await manager.getPostReports(id: groupID, status: "pending") {
                postReports = pr
            }
            if let er = try await manager.getEventReports(id: groupID, status: "pending") {
                eventReports = er
            }
            if let mr = try await manager.getMemberReports(id: groupID, status: "pending") {
                memberReports = mr
            }
            
            handleSuccess()
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    }
    
    private func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }

    private func handleSuccess() {
        status = .success
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    selectedTab == 0 ?
                    Button(action: {
                        withAnimation {
                            selectedTab = 0
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Posts")
                                .foregroundStyle(Color("foreground"))
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                    .background {
                        Color(Color.Background.secondary)
                    }
                    :
                    Button(action: {
                        withAnimation {
                            selectedTab = 0
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Posts")
                                .foregroundStyle(Color("foreground"))
                                .fontWeight(.regular)
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                    .background {
                        Color.clear
                    }
                    
                    selectedTab == 1 ?
                    Button(action: {
                        withAnimation {
                            selectedTab = 1
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Members")
                                .foregroundStyle(Color("foreground"))
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }.padding(.vertical)
                        .background {
                            Color(Color.Background.secondary)
                        }
                    :
                    Button(action: {
                        withAnimation {
                            selectedTab = 1
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Members")
                                .foregroundStyle(Color("foreground"))
                                .fontWeight(.regular)
                            Spacer()
                        }
                    }.padding(.vertical)
                        .background {
                            Color.clear
                        }
                    
                    selectedTab == 2 ?
                    Button(action: {
                        withAnimation {
                            selectedTab = 2
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Events")
                                .foregroundStyle(Color("foreground"))
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }.padding(.vertical)
                        .background {
                            Color(Color.Background.secondary)
                        }
                    :
                    Button(action: {
                        withAnimation {
                            selectedTab = 2
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Events")
                                .foregroundStyle(Color("foreground"))
                                .fontWeight(.regular)
                            Spacer()
                        }
                    }.padding(.vertical)
                        .background {
                            Color.clear
                        }
                }

                TabView(selection: $selectedTab) {
                    Group {
                        if (!postReports.isEmpty) {
                            ScrollView{
                                ForEach(postReports.filter{ $0.status == "pending" }) { report in
                                    PostReportListItem(report: report)
                                }
                            }
                        } else {
                            VStack {
                                Spacer()
                                Text("No Reports")
                                Spacer()
                            }
                        }
                    }.tag(0)
                    Group {
                        if (!memberReports.isEmpty) {
                            ScrollView {
                                ForEach(memberReports.filter{ $0.status == "pending" }) { report in
                                    if let club = session.groupsManager.selected?.club {
                                        MemberReportListItem(club: club, report: report)
                                    }
                                }
                            }
                        } else {
                            VStack {
                                Spacer()
                                Text("No Reports")
                                Spacer()
                            }
                        }
                    }.tag(1)
                    Group {
                        if (!eventReports.isEmpty) {
                            ScrollView{
                                ForEach(eventReports.filter{ $0.status == "pending" }) { report in
                                    EventReportListItem(report: report)
                                }
                            }
                        } else {
                            VStack {
                                Spacer()
                                Text("No Reports")
                                Spacer()
                            }
                        }
                    }.tag(2)
                }.tabViewStyle(.page)
            }.toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await fetchNewReports()
                        }
                    }) {
                        Group {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await fetchNewReports()
            }
        }
    }
}

#Preview {
    GroupReports()
        .environment(SessionStore())
}
