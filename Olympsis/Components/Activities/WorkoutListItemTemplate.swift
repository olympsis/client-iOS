//
//  WorkoutListItemTemplate.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/7/24.
//

import SwiftUI

struct WorkoutListItemTemplate: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 85, height: 85)
                .foregroundColor(.gray)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("yesterday")
                        .bold()
                    Text("NRC Morning Run")
                }.padding(.leading)
                    
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Miles")
                            .font(.caption)
                            .bold()
                            .padding(.bottom, -5)
                        Text("\(00.00, specifier: "%.2f")")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Avg Pace")
                            .font(.caption)
                            .bold()
                            .padding(.bottom, -5)
                        Text("\(0.00)")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Time")
                            .font(.caption)
                            .bold()
                            .padding(.bottom, -5)
                        Text("\(0.00)")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .font(.caption)
                            .bold()
                            .padding(.bottom, -5)
                        Text("\(300, specifier: "%.0f")")
                    }
                }.padding(.horizontal)
                    .padding(.top, 1)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.background)
        }
        .padding(.horizontal, 5)
        .redacted(reason: .placeholder)
            
    }
}

#Preview {
    WorkoutListItemTemplate()
}
