//
//  CreateNewAnnouncement.swift
//  Olympsis
//
//  Created by Joel on 12/1/23.
//

import SwiftUI
import PhotosUI

struct CreateNewAnnouncement: View {
    
    @State var organization: Organization
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
                let id = organization.id else {
            state = .failure
            
            // delete images if we fail to get any of this data
            for img in images ?? [String]() {
                let _ = await uploadObserver.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(img))
            }
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        // create post
        let resp = await session.postObserver.createPost(type: "announcement", owner: uuid, groupId: id, body: text, images: images)
        
        // add to club view
        guard let p = resp else {
            state = .failure
            
            // delete images if we fail to create post
            for img in images ?? [String]() {
                let _ = await uploadObserver.DeleteObject(path: "/olympsis-feed-images", name: GrabImageIdFromURL(img))
            }
            self.presentationMode.wrappedValue.dismiss()
            return
        }
        
        // add data
        let timestamp = Int(Date.now.timeIntervalSince1970)
        let post = Post(id: p.id, type: "announcement", poster: UserSnippet(uuid: uuid, username: user.username, imageURL: user.imageURL), body: text, images: images, likes: nil, comments: nil, createdAt: timestamp, externalLink: "")

        state = .success
        session.posts.append(post)

        self.presentationMode.wrappedValue.dismiss()
    }
    
    func UploadImage() async {
        if let data = selectedImageData {
            // new image
            let imageId = UUID().uuidString
            let res = await uploadObserver.UploadImage(location: "/olympsis-feed-images", fileName: imageId, data: data)
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
                                        .font(.caption)
                                        .textCase(.uppercase)
                                        .frame(height: 30)
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
                    }){ LoadingButton(text: "Create", width: 100, status: $state) }
                        .disabled(state == .loading ? true : false)
                }
            }
            .navigationTitle("New Announcement")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CreateNewAnnouncement(organization: ORGANIZATIONS[0])
}
