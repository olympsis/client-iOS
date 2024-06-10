//
//  MemberReportView.swift
//  Olympsis
//
//  Created by Joel on 3/2/24.
//

import os
import Hermes
import SwiftUI

struct MemberReportView: View {
    
    @State var member: Member
    @State private var issue: String = ""
    @State private var notes: String = ""
    @State private var showProblems: Bool = false
    @State private var state: LOADING_STATE = .pending
    @StateObject private var managementObserver = ManagementObserver()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "member_report_view")
    
    func createReport() async {
        guard issue != "",
              notes != "" else {
            return
        }
        var groupID = ""
        guard let selectedGroup = session.selectedGroup else {
            return
        }
        if let club = selectedGroup.club {
            groupID = club.id ?? ""
        }
        if let org = selectedGroup.organization {
            groupID = org.id ?? ""
        }
        state = .loading
        let report = MemberReportDao(memberID: member.id, groupID: groupID, type: issue, notes: notes)
        do {
            let resp = try await managementObserver.createMemberReport(report: report)
            guard resp else {
                handleFailure()
                return
            }
            handleSuccess()
        } catch {
            log.error("\(error as! NetworkError)")
            handleFailure()
        }
    }
    
    private func handleFailure() {
        state = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            state = .pending
        }
    }

    private func handleSuccess() {
        state = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("What did they do? 😡")
                                .font(.title2)
                            Text("Please report bad actors to keep Olympsis safe")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Please select a problem:")
                            .font(.title2)
                        Text("Help us categorize this report")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        Button(action: { showProblems.toggle() }){
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color("background"))
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(.gray)
                                    .opacity(0.2)
                                Text(issue)
                                    .padding(.horizontal)
                                    .lineLimit(1)
                            }.frame(height: 40)
                        }
                    }.padding(.all)
                        
                    VStack(alignment: .leading) {
                        Text("Additional comments")
                            .font(.title2)
                        Text("Add more context to this report ")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color("background"))
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.gray)
                                .opacity(0.2)
                            TextEditor(text: $notes)
                                .padding(.all, 5)
                                .scrollContentBackground(.hidden)
                                
                        }.frame(height: 150)
                    }.padding(.horizontal)
                    
                }.padding(.vertical)
                    .sheet(isPresented: $showProblems, content: {
                        ScrollView {
                            VStack(alignment: .leading) {
                                Button(action: { issue = "Spam"; showProblems.toggle() }) {
                                    Text("Spam")
                                }.padding(.all)
                                
                                Button(action: { issue = "Nudity"; showProblems.toggle() }) {
                                    Text("Nudity")
                                }.padding(.all)
                                
                                Button(action: { issue = "Harassment"; showProblems.toggle() }) {
                                    Text("Harassment")
                                }.padding(.all)
                                
                                Button(action: { issue = "Something else"; showProblems.toggle() }) {
                                    Text("Something else")
                                }.padding(.all)
                                HStack {
                                    Spacer()
                                }
                            }
                        }.presentationDetents([.medium])
                    })
                
                Button(action: { Task { await createReport() } }) {
                    LoadingButton(text: "Report", image: nil, width: 120, height: 40, color: Color("color-prime"), status: $state)
                }.padding(.top, 50)
                
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Report \(member.user?.username ?? "Member")")
                        .fontWeight(.bold)
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MemberReportView(member: Member(id: "", role: "", user: UserSnippet(uuid: "", username: "johndoe"), joinedAt: 0))
        .environmentObject(SessionStore())
}
