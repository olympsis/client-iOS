//
//  SettingsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/20/24.
//

import SwiftUI

struct ActivitySettingsView: View {
    
    
    @AppStorage("unit_type") private var unitType: String?
    @Environment(WorkoutManager.self) private var manager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Unit of Measurement")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.Background.primary)
                        .padding(.top)
                    VStack {
                        Button(action: { unitType = "kilometers" }) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundStyle(unitType != "miles" ? Color.Brand.primary : Color.Background.primary)
                                .overlay {
                                    Text("Kilometers")
                                        .foregroundStyle(unitType != "miles" ? Color.white : Color.foreground)
                                }
                                .overlay {
                                    if unitType == "kilometers" {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    }
                                }
                        }.buttonStyle(PlainButtonStyle())
                        
                        Button(action: { unitType = "miles" }) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 40)
                                .foregroundStyle(unitType == "miles" ? Color.Brand.primary : Color.Background.primary)
                                .overlay {
                                    Text("Miles")
                                        .foregroundStyle(unitType == "miles" ? Color.white : Color.foreground)
                                }
                                .overlay {
                                    if unitType == "miles" {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    }
                                }
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Settings")
                }
            }
        }
    }
}

#Preview {
    ActivitySettingsView()
        .environment(WorkoutManager())
}
