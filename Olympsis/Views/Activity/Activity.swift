//
//  Activity.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/29/22.
//

import Charts
import SwiftUI

struct Activity: View {
    
    @State private var selectedFilter: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Button(action: {
                            withAnimation(.interpolatingSpring) {
                                selectedFilter = 0
                            }
                        }){
                            Text("This Week")
                                .foregroundColor(selectedFilter == 0 ? .white : .primary)
                        }.padding(.horizontal)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background {
                                if selectedFilter == 0 {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("color-secnd"))
                                } else {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("color-secnd"), lineWidth: 1.0)
                                }
                            }
                        
                        Spacer()
                        Button(action: {
                            withAnimation(.interpolatingSpring) {
                                selectedFilter = 1
                            }
                        }){
                            Text("This Month")
                                .foregroundColor(selectedFilter == 1 ? .white : .primary)
                        }.padding(.horizontal)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background {
                                if selectedFilter == 1 {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("color-secnd"))
                                } else {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("color-secnd"), lineWidth: 1.0)
                                }
                            }
                        
                        Spacer()
                        Button(action: {
                            withAnimation(.interpolatingSpring) {
                                selectedFilter = 2
                            }
                        }){
                            Text("All Time")
                                .foregroundColor(selectedFilter == 2 ? .white : .primary)
                        }.padding(.horizontal)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background {
                                if selectedFilter == 2 {
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundColor(Color("color-secnd"))
                                } else {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("color-secnd"), lineWidth: 1.0)
                                }
                            }
                        
                    }.padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    VStack(alignment: .leading) {
                        Text("_")
                            .font(.largeTitle)
                            .bold()
                        Text("Calories")
                            .font(.title3)
                        
                        Chart {
                            LineMark(
                                x: .value("Day", "Mon"),
                                y: .value("Calories", 0)
                            )
                            LineMark(
                                x: .value("Day", "Tue"),
                                y: .value("Calories", 0)
                            )
                            LineMark(
                                x: .value("Day", "Wed"),
                                y: .value("Calories", 0)
                            )
                            LineMark(
                                x: .value("Day", "Thu"),
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
                    }
                        .padding(.vertical)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Text("Activities")
                            .font(.system(.headline))
                        .padding()
                        Spacer()
                        
//                      getting rid of this for now
//                        Button(action:{}){
//                            Text("View All")
//                               .bold()
//                            Image(systemName: "chevron.down")
//                        }.padding()
//                            .foregroundColor(Color.primary)
                        
                    }.padding(.vertical)
                    
                    Text("We couldn't find any activities 😤")
                    Text("Go out there and join some!")
                }
            }.toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Activity")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

struct Activity_Previews: PreviewProvider {
    static var previews: some View {
        Activity()
    }
}
