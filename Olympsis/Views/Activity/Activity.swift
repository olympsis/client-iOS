//
//  Activity.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/29/22.
//

import Charts
import SwiftUI

struct Activity: View {
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("This Week")
                            .padding(.leading, 20)
                        Spacer()
                    }
                    
                    VStack {
                        Text("N/A")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading)
                        Text("Calories")
                            .font(.title3)
                            .padding(.leading)
                    }.frame(width: SCREEN_WIDTH-20, alignment: .leading)
                        .padding(.top)
                    
                    Chart {
                        LineMark(
                            x: .value("Day", "Mon"),
                            y: .value("Calories", 0)
                        )
                        LineMark(
                            x: .value("Day", "Tues"),
                            y: .value("Calories", 0)
                        )
                        LineMark(
                            x: .value("Day", "Wed"),
                            y: .value("Calories", 0)
                        )
                        LineMark(
                            x: .value("Day", "Thur"),
                            y: .value("Calories", 0)
                        )
                        LineMark(
                            x: .value("Day", "Fri"),
                            y: .value("Calories", 0)
                        )
                        LineMark(
                            x: .value("Day", "Sat"),
                            y: .value("Calories", 0)
                        )
                        LineMark(
                            x: .value("Day", "Sun"),
                            y: .value("Calories", 0)
                        )
                    }
                    
                    HStack {
                        Text("Recent Activities")
                            .font(.system(.headline))
                        .padding()
                        Spacer()
                        Button(action:{}){
                            Text("View All")
                               .bold()
                            Image(systemName: "chevron.down")
                        }.padding()
                            .foregroundColor(Color.primary)
                    }.padding(.top)
                    
                    
                }
            }.navigationTitle("Activity")
        }
    }
}

struct Activity_Previews: PreviewProvider {
    static var previews: some View {
        Activity()
    }
}
