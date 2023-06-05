//
//  DeleteAccountView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/5/23.
//

import os
import SwiftUI

struct DeleteAccountView: View {
    
    @State var progress: Double = 0.0
    @EnvironmentObject var session:SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var log = Logger(subsystem: "com.josephlabs.olympsis", category: "delete_account_view")
    
    var body: some View {
        VStack {
            Text("...Deleting Account...")
                .font(.largeTitle)
                .bold()
            
            ProgressView(value: progress)
                .progressViewStyle(.circular)
                .frame(width: SCREEN_WIDTH - 50)
        }.task {
            let deleted = await session.deleteAccount()
            if deleted {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView().environmentObject(SessionStore())
    }
}
