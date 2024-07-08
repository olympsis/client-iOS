//
//  ActivityActive.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/24.
//

import SwiftUI

struct ActivityPresenter: View {
    
    @EnvironmentObject private var session: SessionStore
    
    var body: some View {
        RunningActivityView()
    }
}

#Preview {
    ActivityPresenter()
        .environmentObject(SessionStore())
}
