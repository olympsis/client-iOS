//
//  ProfileModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI
import Kingfisher

struct ProfileModel: View {
    
    @State private var imageFailed: Bool = false
    @Environment(SessionStore.self) private var session
    
    var imageURL: URL? {
        guard let user = session.user,
              let image = user.imageURL else {
            return nil
        }
        return generateImageURL(image)
    }
    
    var firstName: String {
        guard let user = session.user,
              let name = user.firstName else {
            return "Olympsis"
        }
        return name
    }
    
    var lastName: String {
        guard let user = session.user,
              let name = user.lastName else {
            return "User"
        }
        return name
    }
    
    var bio: String {
        guard let user = session.user,
              let bio = user.bio else {
            return ""
        }
        return bio
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                UserBadgeView(size: .large, imageURL: imageURL)
                
                VStack(alignment: .leading){
                    HStack(){
                        Text(firstName)
                            .font(.system(size: 30))
                            .fontWeight(.black)
                        Text(lastName)
                            .font(.system(size: 30))
                            .fontWeight(.black)
                    }.frame(height: 30)
                }.padding(.leading)
            }
            Text(bio)
                .padding(.top)
                .padding(.bottom)
        }
    }
}

#Preview {
    ProfileModel()
        .environment(SessionStore())
}
