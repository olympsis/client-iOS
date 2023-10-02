//
//  AnnouncementsView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/1/23.
//

import SwiftUI

struct AnnouncementsView: View {
    
    @State var index = "0"
    @Binding var status: LOADING_STATE
    @Binding var announcements: [Announcement]
    
    var body: some View {
        if status == .success {
            VStack {
                TabView(selection: $index){
                    ForEach(announcements){ announcement in
                        AnnouncementView(announcement: announcement).tag(announcement.id)
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(width: SCREEN_WIDTH, height: 500, alignment: .center)
                
                HStack(spacing: 2) {
                    ForEach(announcements, id: \.id) { index in
                        Rectangle()
                            .fill(index.id == self.index ? Color("color-prime") : Color("color-prime").opacity(0.5))
                            .frame(width: 30, height: 5)
                    }
                }.padding()
            }.onChange(of: announcements, perform: { newValue in
                if !announcements.isEmpty {
                    self.index = announcements[0].id
                }
            })
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.gray)
                .opacity(0.3)
                .frame(width: SCREEN_WIDTH, height: 500, alignment: .center)
        }
    }
}

struct AnnouncementsView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementsView(status: .constant(.success), announcements: .constant(ANNOUCEMENTS))
    }
}
