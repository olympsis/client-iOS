//
//  ClubWalletAutoWithdrawl.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/29/25.
//

import SwiftUI

struct ClubWalletAutoWithdrawl: View {
    
    @State private var amount: Double = 50.0
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Auto Withdrawls")
                        .fontWeight(.bold)
                    Text("Automatically withdraw funds at the end of each month.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                Toggle("", isOn: .constant(true))
            }.padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Minimum Amount")
                    .fontWeight(.bold)
                
                TextField("0.00", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .modifier(BackgroundPillModifier())
                    .overlay {
                        HStack {
                            Text("$")
                                .fontWeight(.bold)
                            
                            Spacer()
                        }.padding(.horizontal)
                    }
                
                Text("Only withdraw if balance is above this amount")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 10)
            .padding(.horizontal)
        }
    }
}

#Preview {
    ClubWalletAutoWithdrawl()
}
