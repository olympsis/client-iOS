//
//  ClubWalletView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/28/25.
//

import SwiftUI
import StripePaymentSheet

struct ClubWalletView: View {
    
    @State private var showWithdrawFundsSheet: Bool = false
    @State private var showChangeAccountSheet: Bool = false
    @State private var showChangeAutoWithdrawlSheet: Bool = false
    @State private var customerSheetResult: CustomerSheet.CustomerSheetResult? = nil
    
    private var customerSheet: CustomerSheet = CustomerSheet(configuration: .init(), customer: StripeCustomerAdapter(customerEphemeralKeyProvider: {
        return CustomerEphemeralKey(customerId: "", ephemeralKeySecret: "")
    }))
    
    @Environment(Club.self) private var club
    
    func onCompletion(result: CustomerSheet.CustomerSheetResult) {
        self.customerSheetResult = result
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .top) {
                    VStack(spacing: 4){
                        Text("Available Balance")
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                        
                        Text("$123.45")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Button(action: { showChangeAutoWithdrawlSheet.toggle() }) {
                        Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
                    }
                }
                
                
                HStack {
                    Button(action: { showChangeAccountSheet.toggle() }) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 45)
                            .foregroundStyle(Color.Background.tertiary)
                            .overlay {
                                Text("Change Account")
                                    .fontWeight(.medium)
                            }
                    }
                    
                    
                    
                    Button(action: { showWithdrawFundsSheet.toggle() }) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 45)
                            .foregroundStyle(Color.Brand.primary)
                            .overlay {
                                Text("Withdraw Funds")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                    }
                }.padding(.top)
            }
            .padding(.all)
            .modifier(BackgroundPillModifier())
            .padding(.horizontal)
            .padding(.top, 10)
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Recent Transactions")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Your latest activity")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("View all")
                }
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showWithdrawFundsSheet) {
            ClubWalletWithdraw()
                .presentationDetents([.height(250)])
        }
        .sheet(isPresented: $showChangeAutoWithdrawlSheet) {
            ClubWalletAutoWithdrawl()
                .presentationDetents([.height(200)])
        }
        .customerSheet(
                isPresented: $showChangeAccountSheet,
                customerSheet: customerSheet,
                onCompletion: onCompletion
        )
    }
}

#Preview {
    NavigationStack {
        ClubWalletView()
            .environment(CLUBS[0])
    }
}
