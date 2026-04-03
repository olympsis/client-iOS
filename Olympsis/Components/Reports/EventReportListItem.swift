//
//  EventReportListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/21/24.
//

import os
import SwiftUI

struct EventReportListItem: View {
    
    @State var report: EventReport
    @State private var showEvent: Bool = false
    @StateObject private var observer = ManagementObserver()
    
    var logger: Logger = Logger(subsystem: "com.olympsis.client", category: "event_report_list_item")
    
    private var notes: String {
        guard let n = report.notes else {
            return ""
        }
        return n
    }
    
    func closeReport() async {
        let dao = EventReportDao(status: "closed")
        do {
            let _ = try await observer.updateEventReport(id: report.id, report: dao)
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
            Button(action: { self.showEvent.toggle() }) {
                SimpleButtonLabel(text: "View Event", width: SCREEN_WIDTH-25)
            }.padding(.vertical)
        }.padding(.all).background{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(Color.Background.secondary))
        }
        .fullScreenCover(isPresented: $showEvent, content: {
            if let e = report.event {
                EventView(event: e)
                    .environment(e)
            }
        })
    }
}

#Preview {
    EventReportListItem(report: EVENT_REPORTS[0])
        .environment(SessionStore())
}
