//
//  EventsExplorer.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/2/26.
//

import MapKit
import SwiftUI

struct EventsExplorer: View {
    
    @Binding var router: EventRouter
    @Binding var showMenu: Bool
    @Binding var showNewEvent: Bool
    
    @State private var manager = SearchManager()
    @State private var viewModel = EventsViewModel()
    
    @Environment(SessionStore.self) private var session
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Namespace private var namespace
    
    var body: some View {
        switch horizontalSizeClass {
        case .regular: // iPad
            HStack {
                Map()
                
                ExplorerList(searchText: $viewModel.searchText)
                    .environment(session)
                    .environment(manager)
                    .environment(viewModel)
            }
        default:
            Group {
                Map()
            }.sheet(isPresented: .constant(true)) {
                ExplorerList(searchText: $viewModel.searchText)
                .environment(session)
                .environment(manager)
                .environment(viewModel)
                .presentationDragIndicator(.visible)
                .presentationDetents([.height(100), .medium, .large])
            }
        }
        
    }
}

#Preview {
    EventsExplorer(router: .constant(EventRouter()), showMenu: .constant(false), showNewEvent: .constant(false))
        .environment(SessionStore())
}
