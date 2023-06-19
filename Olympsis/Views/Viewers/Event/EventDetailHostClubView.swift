//
//  EventHostClubView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/13/23.
//

import SwiftUI

struct EventDetailHostClubView: View {
    @State var club: Club
    var body: some View {
        VStack(alignment: .leading){
            Text("Host")
                .font(.title)
                .foregroundColor(.primary)
                .bold()
            
            Text(club.name!)
                .font(.title2)
                .foregroundColor(.primary)
            
            Text(club.description ?? "")
                .padding(.bottom)
        }.frame(width: SCREEN_WIDTH-20, alignment: .leading)
    }
}

struct EventDetailHostClubView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailHostClubView(club: CLUBS[0])
    }
}
