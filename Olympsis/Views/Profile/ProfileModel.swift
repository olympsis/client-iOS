//
//  ProfileModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI

struct ProfileModel: View {
    
    @EnvironmentObject private var session: SessionStore
    
    var imageURL: String {
        guard let user = session.user,
              let image = user.imageURL else {
            return ""
        }
        return image
    }
    
    var firstName: String {
        guard let user = session.user,
              let name = user.firstName else {
            return ""
        }
        return name
    }
    
    var lastName: String {
        guard let user = session.user,
              let name = user.lastName else {
            return ""
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
                AsyncImage(url: URL(string: GenerateImageURL(imageURL))){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .clipShape(Circle())
                                .scaledToFill()
                                .clipped()
                        } else if phase.error != nil {
                            ZStack {
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.red)
                                Color.gray // Acts as a placeholder.
                                    .clipShape(Circle())
                                    .opacity(0.3)
                            }
                        } else {
                            ZStack {
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color("primary-color"))
                                Color.gray // Acts as a placeholder.
                                    .clipShape(Circle())
                                    .opacity(0.3)
                            }
                        }
                }.frame(width: 100, height: 100)
                
                VStack(alignment: .leading){
                    HStack(){
                        Text(firstName)
                            .font(.custom("ITCAvantGardeStd-Bold", size: 30, relativeTo: .largeTitle))
                            .bold()
                        
                        Text(lastName)
                            .font(.custom("ITCAvantGardeStd-Bold", size: 30, relativeTo: .largeTitle))
                            .bold()
                    }.frame(height: 30)
                }.padding(.leading)
            }
            Text(bio)
                .padding(.top)
                .padding(.bottom)
        }
    }
}

struct ProfileModel_Previews: PreviewProvider {
    static var previews: some View {
        ProfileModel()
    }
}
