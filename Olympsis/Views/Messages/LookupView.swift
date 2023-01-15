//
//  LookupView.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/21/22.
//

import SwiftUI
/*
struct LookupView: View {
    
    @State var peek: UserPeek
    
    @State private var bio = ""
    @State private var imageURL = ""
    @State private var showMenu = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    ProfileModel(imageURL: $imageURL, firstName: peek.firstName, lastName: peek.lastName, friendsCount: peek.friends?.count ?? 0, bio: bio)
                        .padding(.leading)
                    
                    // Badges View
                    BadgesView()
                    
                    // Trophies View
                    TrophiesView()
                    
                }.toolbar{
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action:{ self.presentationMode.wrappedValue.dismiss() }){
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text(peek.username)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action:{self.showMenu.toggle()}){
                            Image(systemName: "ellipsis")
                                .foregroundColor(.primary)
                        }.sheet(isPresented: $showMenu) {
                            LookUpMenu(user: peek)
                                .presentationDetents([.height(250)])
                        }
                    }
                }
                .task {
                    if let img = peek.imageURL {
                        self.imageURL = img
                    }
                    if let bio = peek.bio {
                        self.bio = bio
                    }
                }
            }
        }
    }
}

struct LookupView_Previews: PreviewProvider {
    static var previews: some View {
        LookupView(peek: UserPeek(id: "", firstName: "John", lastName: "Doe", username: "johndoe", imageURL: "", bio: "soccer player", sports: ["tennis", "golf"], badges: [Badge](), trophies: [Trophy](), friends: [Friend]()))
    }
}
*/
