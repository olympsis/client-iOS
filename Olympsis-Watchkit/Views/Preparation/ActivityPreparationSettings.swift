//
//  ActivityPreparationSettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/21/24.
//

import SwiftUI

struct ActivityPreparationSettings: View {
    
    var sport: SUPPORTED_SPORTS
    
    @AppStorage("run_type") private var runType: String?
    @AppStorage("unit_type") private var unitType: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                switch sport {
                case .running:
                    VStack(alignment: .leading) {
                        Text("Environment")
                            .font(.caption2)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.Background.primary)
                        
                        HStack {
                            Button(action: { runType = "outdoor" }) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 40)
                                    .foregroundStyle(runType != "indoor" ? Color.colorSecnd : Color.Background.primary)
                                    .overlay {
                                        Text("Outdoor")
                                            .foregroundStyle(runType != "indoor" ? Color.white : Color.Foreground.default)
                                    }
                            }.buttonStyle(PlainButtonStyle())
                                
                            Button(action: { runType = "indoor" }) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 40)
                                    .foregroundStyle(runType == "indoor" ? Color.Brand.secondary : Color.Background.primary)
                                    .overlay {
                                        Text("Indoor")
                                            .foregroundStyle(runType == "indoor" ? Color.white : Color.Foreground.default)
                                    }
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                default:
                    EmptyView()
                }
            }
            .task {
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Settings View")
                }
            }
        }
    }
}

#Preview {
    ActivityPreparationSettings(sport: .running)
}
