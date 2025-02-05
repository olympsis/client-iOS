//
//  MemberReportListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/21/24.
//

import os
import SwiftUI

struct MemberReportListItem: View {
    
    @State var club: Club
    @State var report: MemberReport
    @StateObject private var observer = ManagementObserver()
    
    var logger: Logger = Logger(subsystem: "com.olympsis.client", category: "post_report_list_item")
    
    private var notes: String {
        guard let n = report.notes else {
            return ""
        }
        return n
    }
    
    func closeReport() async {
        let dao = MemberReportDao(status: "closed")
        do {
            let _ = try await observer.updateMemberReport(id: report.id, report: dao)
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
            if let m = report.member {
                MemberView2(member: m)
            }
        }.padding(.all).background{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
        }
    }
}

#Preview {
    MemberReportListItem(club: CLUBS[0], report: MEMBER_REPORTS[0])
        .environment(SessionStore())
}
