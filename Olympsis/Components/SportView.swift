//
//  SportView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI

/// A view to visualize a sport by it's associated icon and name
struct SportView: View {
    
    var sport: SPORTS
    var scale: SCALE
    
    var body: some View {
        switch scale {
        case .Small, .Medium:
            ZStack {
                Circle()
                    .foregroundStyle(Color("background"))
                    .frame(width: 70, height: 70)
                
                VStack(alignment: .center) {
                    switch sport {
                    case .soccer:
                        sport.icon()
                            .resizable()
                            .frame(width: 25, height: 25)
                    case .running:
                        sport.icon()
                            .resizable()
                            .frame(width: 20, height: 25)
                    case .cycling:
                        sport.icon()
                            .resizable()
                            .frame(width: 25, height: 20)
                    case .volleyball:
                        sport.icon()
                            .resizable()
                            .frame(width: 20, height: 25)
                    case .basketball:
                        sport.icon()
                            .resizable()
                            .frame(width: 20, height: 20)
                    case .pickleball:
                        sport.icon()
                            .resizable()
                            .frame(width: 20, height: 20)
                    case .racquetball:
                        sport.icon()
                            .resizable()
                            .frame(width: 20, height: 20)
                    case .tennis:
                        sport.icon()
                            .resizable()
                            .frame(width: 25, height: 25)
                    case .golf:
                        sport.icon()
                            .resizable()
                            .frame(width: 20, height: 30)
                    case .hiking:
                        sport.icon()
                            .resizable()
                            .frame(width: 20, height: 30)
                    case .climbing:
                        sport.icon()
                            .resizable()
                            .frame(width: 25, height: 25)
                    case .spike:
                        sport.icon()
                            .resizable()
                            .frame(width: 25, height: 25)
                    case .football:
                        sport.icon()
                            .resizable()
                            .frame(width: 25, height: 25)
                    case .weights:
                        sport.icon()
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    
                    Text(sport.getName())
                        .font(.custom("HelveticaNeue", size: 8))
                        .textCase(.uppercase)
                        .textScale(.secondary)
                }
            }.frame(width: 70, height: 70)
        case .Large:
            ZStack {
                Circle()
                    .foregroundStyle(Color("background"))
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .center) {
                    switch sport {
                    case .soccer:
                        sport.icon()
                            .resizable()
                            .frame(width: 35, height: 40)
                    case .running:
                        sport.icon()
                            .resizable()
                            .frame(width: 35, height: 40)
                    case .cycling:
                        sport.icon()
                            .resizable()
                            .frame(width: 45, height: 30)
                    case .volleyball:
                        sport.icon()
                            .resizable()
                            .frame(width: 30, height: 40)
                    case .basketball:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .pickleball:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .racquetball:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 35)
                    case .tennis:
                        sport.icon()
                            .resizable()
                            .frame(width: 35, height: 40)
                    case .golf:
                        sport.icon()
                            .resizable()
                            .frame(width: 30, height: 40)
                    case .hiking:
                        sport.icon()
                            .resizable()
                            .frame(width: 30, height: 40)
                    case .climbing:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .spike:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .football:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .weights:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    
                    Text(sport.getName())
                        .font(.caption)
                        .textCase(.uppercase)
                }
            }.frame(width: 100, height: 100)
        case .XLarge:
            ZStack {
                Circle()
                    .foregroundStyle(Color("background"))
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .center) {
                    switch sport {
                    case .soccer:
                        sport.icon()
                            .resizable()
                            .frame(width: 35, height: 40)
                    case .running:
                        sport.icon()
                            .resizable()
                            .frame(width: 35, height: 40)
                    case .cycling:
                        sport.icon()
                            .resizable()
                            .frame(width: 45, height: 30)
                    case .volleyball:
                        sport.icon()
                            .resizable()
                            .frame(width: 30, height: 40)
                    case .basketball:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .pickleball:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .racquetball:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 35)
                    case .tennis:
                        sport.icon()
                            .resizable()
                            .frame(width: 35, height: 40)
                    case .golf:
                        sport.icon()
                            .resizable()
                            .frame(width: 30, height: 40)
                    case .hiking:
                        sport.icon()
                            .resizable()
                            .frame(width: 30, height: 40)
                    case .climbing:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .spike:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .football:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    case .weights:
                        sport.icon()
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    
                    Text(sport.getName())
                        .font(.caption)
                        .textCase(.uppercase)
                }
            }.frame(width: 100, height: 100)
        }
    }
}

#Preview {
    SportView(sport: .weights, scale: .Medium)
}
