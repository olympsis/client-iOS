//
//  ClubWalletWithdraw.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/29/25.
//

import SwiftUI

struct ClubWalletWithdraw: View {
    
    @State private var amount: Double = 0.0
    @State private var balance: Double = 192.17
    @State private var selectedAccount: String = "xxx"
    @State private var loadingState: LOADING_STATE = .pending
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Amount to withdraw")
                    .fontWeight(.bold)
                
                TextField("0.00", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 40)
                    .padding(.vertical)
                    .modifier(BackgroundPillModifier())
                    .overlay {
                        HStack {
                            Text("$")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Stepper(value: $amount, in: 0...balance, step: 0.01) {
                                
                            }
                        }.padding(.horizontal)
                    }
                    
                
                HStack {
                    Text("Available: \(balance, specifier: "%0.2f")")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Button(action: { amount = balance }) {
                        Text("Max")
                            .font(.callout)
                            .fontWeight(.bold)
                    }
                }
                
            }
            .padding([.bottom, .horizontal])
            
//            VStack(alignment: .leading) {
//                Text("Withdrawal account")
//                    .fontWeight(.bold)
//                
//                Picker("Select Account", selection: $selectedAccount) {
//                    Text("xxx")
//                    Text("xxxx")
//                }
//                .frame(height: 100)
//                .pickerStyle(.wheel)
//                
//                
//                HStack {
//                    Spacer()
//                }
//            }.padding(.all)
            
            HStack {
                LoadingButton(text: "Withdraw", status: $loadingState)
                    .padding()
            }
        }
    }
}

#Preview {
    ClubWalletWithdraw()
}
