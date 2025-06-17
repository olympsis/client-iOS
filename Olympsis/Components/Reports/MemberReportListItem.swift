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
            if let m = report.member {
                MemberListItem(member: Member(id: nil, role: "member", user: m, joinedAt: nil), enableMenu: false)
                    .environmentObject(club)
            }
            
            HStack {
                Spacer()
                
                Text(calculateTimeAgo(from: report.createdAt))
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.all)
        .background{
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(Color(Color.Background.secondary))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.primary.opacity(0.15), lineWidth: 1)
        }
    }
}

#Preview {
    MemberReportListItem(club: CLUBS[0], report: MEMBER_REPORTS[0])
        .environment(SessionStore())
        .padding(.horizontal, 10)
}
