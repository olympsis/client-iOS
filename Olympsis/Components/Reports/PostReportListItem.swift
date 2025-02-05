//
//  PostReportListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/21/24.
//

import os
import SwiftUI

struct PostReportListItem: View {
    
    @State var report: PostReport
    @State private var showPost: Bool = false
    @StateObject private var observer = ManagementObserver()
    
    var logger: Logger = Logger(subsystem: "com.olympsis.client", category: "post_report_list_item")
    
    private var notes: String {
        guard let n = report.notes else {
            return ""
        }
        return n
    }
    
    func closeReport() async {
        let dao = PostReportDao(status: "closed")
        do {
            let _ = try await observer.updatePostReport(id: report.id, report: dao)
            report.status = "closed"
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await closeReport()
                        }
                    } label: {
                        Text("Close Report")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            HStack{
                Text("Reason:")
                    .fontWeight(.bold)
                Text(report.type)
                Spacer()
            }
            HStack(alignment: .top) {
                Text("Notes:")
                    .fontWeight(.bold)
                Text(notes)
                Spacer()
            }
            HStack {
                Text("Created at:")
                    .fontWeight(.bold)
                Text(calculateTimeAgo(from: report.createdAt))
                Spacer()
            }
            Button(action: { self.showPost.toggle() }) {
                SimpleButtonLabel(text: "View Post", width: SCREEN_WIDTH-25)
            }.padding(.vertical)
        }.padding(.all).background{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
        }
        .fullScreenCover(isPresented: $showPost, content: {
            if let p = report.post {
                PostViewer(post: p)
            }
        })
    }
}

#Preview {
    PostReportListItem(report: POST_REPORTS[0])
        .environment(SessionStore())
}
