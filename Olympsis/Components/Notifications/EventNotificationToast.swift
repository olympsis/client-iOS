//
//  EventNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/8/24.
//

import SwiftUI
import Kingfisher

struct EventNotificationToast: View {
    
    var title: String
    var content: String
    var eventImg: String?
    
    var body: some View {
        HStack {
            if let img = eventImg,
               let url = generateImageURL(img) {
                KFImage(url)
                    .placeholder({
                        ImageLoadingView()
                    })
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 45)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 35, height: 45)
                    .foregroundStyle(.gray)
                    .overlay {
                        Image(systemName: "mountain.2")
                    }
            }
            
            VStack{
                Text("\(title)")
                    .bold()
                +
                Text(" \(content)")
            }
            .foregroundStyle(Color("foreground"))
            .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 60)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
                .padding(.horizontal, 10)
        }
    }
}

#Preview {
    EventNotificationToast(title: "[Sunday Pickup]", content: "event is starting!", eventImg: "event-images/B4CC06C8-76C7-422A-B63F-7E63D31DBCD7.jpeg")
}
