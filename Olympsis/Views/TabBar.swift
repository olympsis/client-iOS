//
//  TabBar.swift
//  Olympsis
//
//  Created by Joel Joseph on 10/20/22.
//

import SwiftUI

struct TabBar: View {
    @Binding var currentTab: Tab
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue){ tab in
                    Button() {
                        withAnimation(.easeInOut(duration: 0.2)){
                            currentTab = tab
                        }
                    } label: {
                        Image(systemName: currentTab == tab ? tab.getIcon() + ".fill" : tab.getIcon())
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(currentTab == tab ? Color("secondary-color") : .white )
                    }
                }
            }.frame(maxWidth: .infinity)
            
        }.frame(height: 20)
        .padding(.bottom, 10)
        .padding([.horizontal, .top])
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        ViewContainer()
    }
}
