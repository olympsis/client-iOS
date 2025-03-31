//
//  ClubsList2.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/15/23.
//

import SwiftUI

struct ClubsList2: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ClubsList()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{ dismiss() }){
                            Image(systemName: "chevron.left")
                        }
                    }
                }
                .navigationBarBackButtonHidden()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ClubsList2_Previews: PreviewProvider {
    static var previews: some View {
        ClubsList2()
            .environment(SessionStore())
    }
}
