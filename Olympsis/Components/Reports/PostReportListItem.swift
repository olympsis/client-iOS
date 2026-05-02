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
                        Text(String(localized: "report-close", table: "Settings"))
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            HStack{
                Text(String(localized: "report-reason", table: "Settings"))
                    .fontWeight(.bold)
                Text(report.type)
                Spacer()
            }
            HStack(alignment: .top) {
                Text(String(localized: "report-notes", table: "Settings"))
                    .fontWeight(.bold)
                Text(notes)
                Spacer()
            }
            HStack {
                Text(String(localized: "report-created-at", table: "Settings"))
                    .fontWeight(.bold)
                Text(calculateTimeAgo(from: report.createdAt))
                Spacer()
            }
            Button(action: { self.showPost.toggle() }) {
                SimpleButtonLabel(text: "View Post", width: SCREEN_WIDTH-25)
            }.padding(.vertical)
        }.padding(.all).background{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(Color.Background.secondary))
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
