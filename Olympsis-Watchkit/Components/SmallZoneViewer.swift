//
//  SmallZoneViewer.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/7/25.
//

import SwiftUI

struct SmallZoneViewer: View {
    
    var zone: Int
    private var zones: [Int] {
        switch zone {
        case 1, 2:
            return [1, 2, 3]
        case 3:
            return [2, 3, 4]
        case 4, 5:
            return [3, 4, 5]
        default:
            return []
        }
    }
    
    private var columns: [GridItem] {
        switch zone {
        case 1:
            [
                GridItem(.flexible(minimum: 15, maximum: 20)),
                GridItem(.flexible(minimum: 10, maximum: 10)),
                GridItem(.flexible(minimum: 10, maximum: 10))
            ]
        case 2:
            [
                GridItem(.flexible(minimum: 10, maximum: 10)),
                GridItem(.flexible(minimum: 15, maximum: 20)),
                GridItem(.flexible(minimum: 10, maximum: 10))
            ]
        case 3:
            [
                GridItem(.flexible(minimum: 10, maximum: 10)),
                GridItem(.flexible(minimum: 15, maximum: 20)),
                GridItem(.flexible(minimum: 10, maximum: 10))
            ]
        case 4:
            [
                GridItem(.flexible(minimum: 10, maximum: 10)),
                GridItem(.flexible(minimum: 15, maximum: 20)),
                GridItem(.flexible(minimum: 10, maximum: 10))
            ]
        case 5:
            [
                GridItem(.flexible(minimum: 10, maximum: 10)),
                GridItem(.flexible(minimum: 10, maximum: 10)),
                GridItem(.flexible(minimum: 15, maximum: 20))
            ]
        default:
            []
        }
    }
    
    func getColorForZone(_ zone: Int) -> Color {
        switch zone {
        case 1:
            return .blue
        case 2:
            return .yellow
        case 3:
            return .green
        case 4:
            return .orange
        case 5:
            return .red
        default:
            return .black
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(zones, id: \.self) { z in
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(getColorForZone(z))
                    .overlay {
                        if z == zone {
                            Text("\(z)")
                                .foregroundStyle(.black)
                                .font(.headline)
                        }
                    }
                    .frame(height: z == zone ? 20 : 15)
                    .padding(-1)
            }
        }
    }
}

#Preview {
    SmallZoneViewer(zone: 1)
}
