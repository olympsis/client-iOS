//
//  LookUp.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/22/22.
//

import SwiftUI
/*
struct LookUp: View {
    @State var users = [UserPeek]()
    
    @State var username:String = ""
    @State var status: LOADING_STATE = .success
    @State var showCancel: Bool = false
    @State var showDetails: Bool = false
    
    @StateObject private var userObserver = UserObserver()
    
    func performSearch(callback: @escaping ()async->Void) {
        Task.init {
            await callback()
        }
    }
    func search() async {
        await MainActor.run {
            status = .loading
        }
        do {
            let usr = try await userObserver.Lookup(username: username)
            if let usr = usr {
                await MainActor.run{
                    users = [usr]
                    status = .success
                }
            }
        } catch {
            print(error)
            await MainActor.run {
                status = .failure
            }
        }
        
    }
    var body: some View {
        VStack {
            HStack (alignment: .center) {
                SearchBar(text: $username, onCommit: {
                    showCancel = false
                    performSearch(callback: search)
                    username = ""
                }).onTapGesture {
                        if !showCancel {
                            showCancel = true
                        }
                    }
                .frame(maxWidth: SCREEN_WIDTH-10, maxHeight: 40)
                .padding(.leading, 5)
                .padding(.trailing, 5)
                if showCancel {
                    Button(action:{
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        showCancel = false
                    }){
                        Text("Cancel")
                            .foregroundColor(.gray)
                            .frame(height: 40)
                    }.padding(.trailing)
                }
            }
            ScrollView(showsIndicators: false) {
                VStack {
                    if status == .pending {
                        Text("Search Users")
                            .foregroundColor(.gray)
                            .frame(height: SCREEN_HEIGHT/2)
                    } else if status == .loading {
                        ProgressView()
                            .padding(.top)
                    } else if status == .success {
                        ForEach(users) { user in
                            Button(action:{self.showDetails.toggle()}){
                                HStack {
                                    AsyncImage(url: URL(string: "https://storage.googleapis.com/diesel-nova-366902.appspot.com/" + (user.imageURL ?? ""))){ phase in
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
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.red)
                                                    Color.gray // Acts as a placeholder.
                                                        .clipShape(Circle())
                                                        .opacity(0.3)
                                                }
                                            } else {
                                                ZStack {
                                                    Image(systemName: "person")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(Color("primary-color"))
                                                    Color.gray // Acts as a placeholder.
                                                        .clipShape(Circle())
                                                        .opacity(0.3)
                                                }
                                            }
                                    }.frame(width: 50, height: 50)
                                        .padding(.trailing, 5)
                                        .padding(.leading)
                                    
                                    VStack (alignment: .leading){
                                        Text(user.username)
                                            .font(.headline)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.primary)
                                        Text("\(user.firstName) \(user.lastName)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                }
                            }.fullScreenCover(isPresented: $showDetails) {
                                LookupView(peek: user)
                            }
                            .padding(.top)
                            
                        }
                    } else if status == .failure {
                        Text("User not found")
                            .foregroundColor(.gray)
                            .frame(height: SCREEN_HEIGHT/2)
                    }
                }
            }
        }
    }
}

struct LookUp_Previews: PreviewProvider {
    static var previews: some View {
        LookUp()
    }
}
*/
