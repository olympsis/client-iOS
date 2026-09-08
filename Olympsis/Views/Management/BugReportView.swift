//
//  BugReportView.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/10/24.
//

import os
import SwiftUI

struct BugReportView: View {
    
    @State private var notes: String = ""
    @State private var showProblems: Bool = false
    @State private var state: LOADING_STATE = .pending
    
    private let managementObserver = ManagementService()
    
    @Environment(\.dismiss) private var dismiss
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "bug_report_view")
    
    func createReport() async {
        guard notes != "" else {
            return
        }
        state = .loading
        let report = BugReportDao(notes: notes)
        do {
            let resp = try await managementObserver.createBugReport(report: report)
            guard resp else {
                handleFailure()
                return
            }
            handleSuccess()
        } catch {
            log.error("\(error.localizedDescription)")
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
        ScrollView {
            VStack(alignment: .center){
                Text(String(localized: "report-sub-title", table: "Settings"))
                    .font(.subheadline)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                VStack(alignment: .leading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(Color.Background.secondary))
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.gray)
                            .opacity(0.2)
                        TextEditor(text: $notes)
                            .padding(.all, 5)
                            .scrollContentBackground(.hidden)
                    }.frame(height: 250)
                }.padding(.all)
                Spacer()
            }.padding(.vertical)
            
            Button(action: { Task { await createReport() } }) {
                LoadingButton(text: String(localized: "report-button-text", table: "Settings"), image: nil, width: 120, height: 40, color: Color("color-prime"), status: $state)
            }.padding(.top, 50)
            
        }
        .navigationTitle(String(localized: "report-title", table: "Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BugReportView()
    }
}
