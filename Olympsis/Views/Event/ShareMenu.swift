//
//  ShareMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/21/24.
//

import SwiftUI

struct ShareMenu: View {
    
    var event: Event
    var venue: Venue
    @State private var showShareView = false
    @State private var sharingMethod: SHARE_METHOD = .image
    
    var body: some View {
        VStack {
            Group {
                Text("Share Event")
                    .padding(.top)
                    .fontWeight(.bold)
                
                HStack {
                    SquareIconButton(icon: Image(systemName: "photo"), text: "Export", size: CGSize(width: 80, height: 80), imageSize: CGSize(width: 35, height: 25)) {
                        sharingMethod = .image
                        showShareView = true
                    }
                    
//                    SquareIconButton(icon: Image("logos/instagram"), text: "Instagram", size: CGSize(width: 80, height: 80), imageSize: CGSize(width: 35, height: 35)) {
//                        sharingMethod = .instagram
//                        showShareView = true
//                    }
//                    
//                    SquareIconButton(icon: Image("logos/facebook"), text: "Facebook", size: CGSize(width: 80, height: 80), imageSize: CGSize(width: 40, height: 40)) {
//                        sharingMethod = .facebook
//                        showShareView = true
//                    }
//                    
//                    SquareIconButton(icon: Image("logos/x"), text: "X", size: CGSize(width: 80, height: 80), imageSize: CGSize(width: 40, height: 40)) {
//                        sharingMethod = .x
//                        showShareView = true
//                    }
                }
            }
            
            Spacer()
        }
        .background(Color("background-color/secondary"))
        .presentationDragIndicator(.visible)
        .fullScreenCover(isPresented: $showShareView) {
            EventSharingView(event: event, venue: venue, method: sharingMethod)
        }
    }
}

#Preview {
    ShareMenu(event: EVENTS[0], venue: FIELDS[0])
}
