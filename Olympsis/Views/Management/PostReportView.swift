//
//  PostReportView.swift
//  Olympsis
//
//  Created by Joel on 3/3/24.
//

import SwiftUI

struct PostReportView: View {
    
    @State var post: Post
    @State private var issue: String = ""
    @State private var notes: String = ""
    @State private var showProblems: Bool = false
    @State private var state: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    
    func createReport() async {}
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("What is wrong with this post?")
                                .font(.title2)
                            Text("Please report bad actors to keep our groups safe")
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
                    Text("Report")
                        .fontWeight(.bold)
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PostReportView(post: Post(id: "", type: "", poster: UserSnippet(uuid: "", username: "johndoe"), body: "", event: nil, images: nil, likes: nil, comments: nil, createdAt: 0, externalLink: nil))
}
