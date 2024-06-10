//
//  LogViewer.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/9/24.
//

import os
import SwiftUI

struct LogViewer: View {
    
    @State private var filter: String = ""
    @State private var logs = [LogEntry]()
    @State private var status: LOADING_STATE = .pending
    
    private var manager = LoggingManagement()
    private var log = Logger(subsystem: "com.olympsis.client", category: "log_viewer")
    
    func fetchLogs() async {
        status = .loading
        let predicate = NSPredicate(format: "subsystem IN %@", [
            "com.olympsis.client",
            "com.josephlabs.hermes"
        ])
        do {
            guard let time = Calendar.current.date(byAdding: .hour, value: -30, to: Date.now),
                  let entries = try await manager.fetchLogs(since: time, predicateFormat: predicate.predicateFormat) else {
                return
            }
            logs = entries
        } catch {
            log.error("Failed to fetch logs: \(error.localizedDescription)")
        }
        status = .success
    }
    
    var body: some View {
        Group {
            if status == .loading {
                VStack {
                    ProgressView()
                }
            } else {
                ScrollView {
                    if !logs.isEmpty {
                        ForEach(logs.reversed()) {
                            LogListItem(entry: $0)
                        }
                    } else {
                        Text("No Logs Found")
                    }
                }
            }
        }
        .navigationTitle("Logs")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .refreshable {
            await fetchLogs()
        }
        .task {
            await fetchLogs()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button(action: { filter = "com.olympsis.client" }) {
                        Text("Client")
                    }
                    Button(action: { filter = "com.josephlabs.hermes" }) {
                        Text("Hermes")
                    }
                    Button(action: { filter = "" }) {
                        Text("Clear")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                Button(action: { }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LogViewer()
    }
}
