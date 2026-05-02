//
//  ExplorerList.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/2/26.
//

import SwiftUI

struct ExplorerList: View {
    
    @Environment(SessionStore.self) private var session
    @Environment(EventsViewModel.self) private var viewModel
    
    var body: some View {
        // @Bindable lets us derive Bindings from the @Observable view model.
        // It must live inside `body` (or be declared with @Bindable var) because
        // the view model itself comes from @Environment, not @State.
        @Bindable var vm = viewModel
        
        
        ScrollView {
            HStack {
                Spacer()
                    
                Picker("Page", selection: $vm.page) {
                    ForEach(EVENT_EXPLORER_STATE.allCases, id: \.self) { page in
                        Text(page.localized).tag(page)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: SCREEN_WIDTH/2)


                Spacer()
            }.padding(.top)
        }
    }
}

#Preview {
    ExplorerList()
        .environment(SessionStore())
        .environment(EventsViewModel())
}
