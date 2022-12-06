//
//  ProfileModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/6/22.
//

import SwiftUI

struct ProfileModel: View {
    
    @State var imageURL     : String
    @State var firstName    : String
    @State var lastName     : String
    @State var friendsCount : Int
    @State var bio          : String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: URL(string: imageURL)){ phase in
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
                    
                    if friendsCount > 0 {
                        Text("\(friendsCount) friends")
                            .frame(height: 30)
                    } else {
                        Text("no friends")
                            .frame(height: 30)
                    }
                    
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
        ProfileModel(imageURL: "https://storage.googleapis.com/olympsis-1/profile-img/109510499_4009879105753576_2952872539472995744_n.jpg", firstName: "John", lastName: "Doe", friendsCount: 0, bio: "I love to play Sports.")
    }
}
