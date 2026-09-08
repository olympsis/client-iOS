//
//  CompetitionFormatView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/12/25.
//

import SwiftUI

struct CompetitionFormatView: View {
    
    var format: CompetitionFormats
    var selected: Bool = false
    
    private var text: String {
        return format.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    var body: some View {
        Text(text)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(selected ? Color.colorTert.opacity(0.7) : Color.Background.secondary )
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1.5)
                }
            }
    }
}

#Preview {
    CompetitionFormatView(format: .winnerStaysOn)
}
