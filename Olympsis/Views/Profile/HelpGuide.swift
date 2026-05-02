//
//  HelpGuide.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/24.
//

import SwiftUI

struct HelpGuide: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            HStack {
                Text(String(localized: "help-title", table: "Settings"))
                    .font(.title3)
                    .bold()
                    .padding(.all)
                Spacer()
            }
            
            Text(String(localized: "help-intro", table: "Settings"))
                .padding(.horizontal)
            
            GroupBox {
                Text(String(localized: "help-bug-reports-body", table: "Settings"))
            } label: {
                Text(String(localized: "help-bug-reports", table: "Settings"))
            }
            
            GroupBox {
                Text(String(localized: "help-user-reports-body", table: "Settings"))
            } label: {
                Text(String(localized: "help-user-reports", table: "Settings"))
            }
            
            GroupBox {
                Text(String(localized: "help-email-body", table: "Settings"))
            } label: {
                Text(String(localized: "help-email", table: "Settings"))
            }
            
            GroupBox {
                Text(String(localized: "help-social-body", table: "Settings"))
            } label: {
                Text(String(localized: "help-social", table: "Settings"))
            }
            
            Text(String(localized: "help-closing", table: "Settings"))
            .padding(.horizontal)
        }
        .navigationTitle(String(localized: "setting-help", table: "Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HelpGuide()
    }
}
