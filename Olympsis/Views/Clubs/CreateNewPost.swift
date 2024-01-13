//
//  CreateNewPost.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/22.
//

import SwiftUI
import PhotosUI

struct CreateNewPost: View {
    
    @State var club: Club
    @Binding var posts: [Post]
    @State private var state: LOADING_STATE = .pending
    @State private var text: String = ""
    @State private var images: [String]?
    @State private var showCompletedToast = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @StateObject var uploadObserver = UploadObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    func CreateNewPost() async {
        guard text != "" || text.count > 5 else {
            return
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        // upload image
        state = .loading
        if selectedImageData != nil {
            await UploadImage()
        }
        
        guard let user = session.user,
                let uuid = user.uuid,
                let id = club.id else {
            state = .failure
            
            // delete images if we fail to get any of this data
            for img in images ?? [String]() {
                let _ = await uploadObserver.DeleteObject(path: "/feed-images", name: GrabImageIdFromURL(img))
            }
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        // add to club view
        guard let createdPost = await session.postObserver.createPost(type: "post", owner: uuid, groupId: id, body: text, images: images) else {
            state = .failure
            
            // delete images if we fail to create post
            for img in images ?? [String]() {
                let _ = await uploadObserver.DeleteObject(path: "/feed-images", name: GrabImageIdFromURL(img))
            }
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        // add data
        let timestamp = Int(Date.now.timeIntervalSince1970)
        let post = Post(id: createdPost.id, type: "post", poster: UserSnippet(uuid: uuid, username: user.username, imageURL: user.imageURL), body: text, images: images, likes: nil, comments: nil, createdAt: timestamp, externalLink: "")
        
        await MainActor.run {
            state = .success
            self.posts.append(post)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func UploadImage() async {
        if let data = selectedImageData {
            // new image
            let imageId = UUID().uuidString
            let res = await uploadObserver.UploadImage(location: "/feed-images", fileName: imageId, data: data)
            if res {
                images = ["feed-images/\(imageId).jpeg"]
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading){
                    Text("What's up?")
                        .bold()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(uiColor: .tertiarySystemGroupedBackground))
                            .opacity(0.3)
                        TextEditor(text: $text)
                            .scrollContentBackground(.hidden)
                            .tint(Color("color-prime"))
                    }
                }.frame(width: SCREEN_WIDTH-25, height: 200)
                    .padding(.top)
                HStack {
                    Text("Image")
                        .bold()
                    Spacer()
                    if selectedImageData == nil {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 100, height: 30)
                                        .foregroundColor(Color("color-prime"))
                                    Text("upload")
                                        .foregroundColor(.white)
                                        .frame(height: 30)
                                        .font(.caption)
                                        .textCase(.uppercase)
                                }
                            }.onChange(of: selectedItem) { newItem in
                                Task {
                                    // Retrive selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        withAnimation(.easeIn){
                                            selectedImageData = data
                                        }
                                    }
                                }
                            }
                    } else {
                        Button(action:{
                            withAnimation(.easeOut){
                                selectedImageData = nil
                                selectedItem = nil
                            }
                        }){
                            Image(systemName: "x.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(Color("color-prime"))
                        }
                    }
                }.frame(width: SCREEN_WIDTH-25, height: 50)
                if let imgData = selectedImageData {
                    let img = UIImage(data: imgData)
                    if let i = img {
                        Image(uiImage: i)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: SCREEN_WIDTH-25, height: 250)
                    }
                    
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement:.navigationBarLeading){
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .tint(Color("color-prime"))
                    }
                }
                ToolbarItem(placement:.navigationBarTrailing){
                    Button(action:{
                        Task{
                            await CreateNewPost()
                        }
                    }){ LoadingButton(text: "Create", width: 70, status: $state) }
                        .disabled(state == .loading ? true : false)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost(club: CLUBS[0], posts: .constant(POSTS)).environmentObject(SessionStore())
    }
}
