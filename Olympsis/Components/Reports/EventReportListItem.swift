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
            Button(action: { self.showEvent.toggle() }) {
                SimpleButtonLabel(text: "View Event", width: SCREEN_WIDTH-25)
            }.padding(.vertical)
        }.padding(.all).background{
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
        }
        .fullScreenCover(isPresented: $showEvent, content: {
            if let e = report.event {
                EventView(event: .constant(e))
            }
        })
    }
}

#Preview {
    EventReportListItem(report: EVENT_REPORTS[0])
        .environmentObject(SessionStore())
}
