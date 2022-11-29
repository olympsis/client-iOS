//
//  CreateNewPost.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI
import AlertToast

struct CreateNewPost: View {
    
    enum Status {
        case pending
        case loading
        case failed
        case done
    }
    
    @State var clubId: String
    
    @State private var status: Status = .pending
    @State private var text = ""
    @State private var images = [String]()
    @State private var showCompletedToast = false
    
    @StateObject private var postObserver = PostObserver()
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func CreateNewPost() async {
        if text == "" || text.count < 5 {
            return
        }
        // later add function to upload images and get urls before creating post object
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        if let user = session.user {
            let _ = await postObserver.createPost(owner: user.uuid, clubId: clubId, body: text)
            self.showCompletedToast.toggle()
            // later we might want to do something with the post result
            // for now i will just make it so that on dismiss of this view
            // the clubs page will fetch the posts again.
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading){
                    Text("Text")
                        .bold()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
                        TextEditor(text: $text)
                            .scrollContentBackground(.hidden)
                            .padding(.leading)
                            .tint(Color("primary-color"))
                            
                            
                    }
                }.frame(width: SCREEN_WIDTH-25, height: 200)
                    .padding(.top)
                HStack {
                    Text("Image")
                        .bold()
                    Spacer()
                    Button(action:{}){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 30)
                                .foregroundColor(Color("secondary-color"))
                                .opacity(0.3)
                            Text("upload")
                                .foregroundColor(Color("primary-color"))
                                .frame(height: 30)
                        }
                    }
                }.frame(width: SCREEN_WIDTH-25, height: 50)
                Spacer()
            }.toast(isPresenting: $showCompletedToast,duration: 1, alert: {
                AlertToast(displayMode: .banner(.pop), type: .regular, title: "Post Created!", style: .style(titleColor: .white, titleFont: .callout))
            }, completion: {
                self.presentationMode.wrappedValue.dismiss()
            })
            .toolbar {
                ToolbarItem(placement:.navigationBarLeading){
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .tint(Color("primary-color"))
                    }
                }
                ToolbarItem(placement:.navigationBarTrailing){
                    Button(action:{
                        Task{
                            await CreateNewPost()
                        }
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("primary-color"))
                                .frame(width: 70, height: 30)
                            Text("Create")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost(clubId: "")
    }
}
