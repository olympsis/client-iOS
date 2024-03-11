//
//  BugReportView.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/10/24.
//

import SwiftUI

struct BugReportView: View {
    
    @State private var issue: String = ""
    @State private var notes: String = ""
    @State private var showProblems: Bool = false
    @State private var state: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    
    func createReport() async {}
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center){
                    Text("If the app or a feature is not working as expected, please let us know the details so we can make Olympsis better")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    VStack(alignment: .leading) {
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
                        }.frame(height: 250)
                    }.padding(.all)
                    Spacer()
                }.padding(.vertical)
                
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
                    Text("Report a technical problem")
                        .fontWeight(.bold)
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BugReportView()
}
