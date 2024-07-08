//
//  ActiveRunningMetrics.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/6/24.
//

import SwiftUI

struct RunningMetrics: View {
    
    @Binding var calories: Int
    @Binding var time: Int
    @Binding var bpm: Int
    @Binding var distance: Double
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .center) {
                    Text("Calories")
                        .font(.callout)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                    Text(String(format: "%.0f", calories))
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(width: (SCREEN_WIDTH/2)-15)
                .padding(.vertical)
                .background {
                    Color.background
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .center) {
                    Text("Time")
                        .font(.callout)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                    Text(formatEllapsedTime(seconds: time))
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(width: (SCREEN_WIDTH/2)-15)
                .padding(.vertical)
                .background {
                    Color.background
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            HStack {
                VStack(alignment: .center) {
                    Text("bmp")
                        .font(.callout)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                    HStack {
                        Text(String(format: "%.0f", bpm))
                            .font(.title)
                            .fontWeight(.bold)
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        
                    }
                }
                .frame(width: (SCREEN_WIDTH/2)-15)
                .padding(.vertical)
                .background {
                    Color.background
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .center) {
                    Text("Distance")
                        .font(.callout)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                    Text(String(distance) + " mi")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(width: (SCREEN_WIDTH/2)-15)
                .padding(.vertical)
                .background {
                    Color.background
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

#Preview {
    RunningMetrics(calories: .constant(340), time: .constant(1853), bpm: .constant(145), distance: .constant(4.12))
}
