//
//  NewPostNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/8/24.
//

import SwiftUI
import Kingfisher

struct UserNotificationToast: View {
    
    var title: String
    var name: String
    var content: String
    var profileImg: String?
    
    var body: some View {
        HStack {
            if let img = profileImg,
               let url = generateImageURL(img) {
                KFImage(url)
                    .placeholder({
                        ImageLoadingView()
                    })
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .clipped()
                    .clipShape(Circle())
            } else {
                Circle()
                    .foregroundStyle(.gray)
                    .frame(width: 45, height: 45)
                    .overlay {
                        Image(systemName: "person")
                    }
            }
            
            VStack{
                Text("\(title)")
                    .bold()
                +
                Text(" \(name)")
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
    UserNotificationToast(title: "[SLCFC]", name: "johndoe", content: "created a new Post!", profileImg: "event-images/B4CC06C8-76C7-422A-B63F-7E63D31DBCD7.jpeg")
}
