//
//  ShareMenu.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/21/24.
//

import SwiftUI

struct ShareMenu: View {
    
    var event: Event
    /// Optional because the event screen presents this sheet before the venue
    /// lookup finishes — and that lookup can fail outright. Reading `venues[0]`
    /// here is what used to crash the share button on a slow network.
    var venue: Venue?
    
    @Binding var showToast: Bool
    @State private var showShareView: Bool = false
    @State private var sharingMethod: SHARE_METHOD = .image
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Group {
                Text("Share Event")
                    .padding(.top)
                    .fontWeight(.bold)
                
                HStack {
                    SquareIconButton(icon: Image(systemName: "link"), text: "Copy Link", size: CGSize(width: 80, height: 80), imageSize: CGSize(width: 35, height: 35)) {
                        UIPasteboard.general.setValue("https://olympsis.com/events/\(event.id)", forPasteboardType: "public.plain-text")
                        showToast.toggle()
                        dismiss()
                    }
                    
//                    SquareIconButton(icon: Image(systemName: "photo"), text: "Export", size: CGSize(width: 80, height: 80), imageSize: CGSize(width: 35, height: 25)) {
//                        sharingMethod = .image
//                        showShareView = true
//                    }
                    
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
                    
                    Spacer()
                }.padding(.horizontal)
            }
            
            Spacer()
        }
        .presentationDragIndicator(.visible)
        .fullScreenCover(isPresented: $showShareView) {
            // The image templates need a venue to draw; without one there is
            // nothing to export, so the cover simply doesn't open.
            if let venue {
                EventSharingView(event: event, venue: venue, method: sharingMethod)
            }
        }
    }
}

#Preview {
    ShareMenu(event: EVENTS[0], venue: VENUES[0], showToast: .constant(false))
}
