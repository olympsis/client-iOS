//
//  EventImagePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/2/24.
//

import SwiftUI
import Kingfisher

struct EventImagePicker: View {
    
    @State private var showImagePicker: Bool = false
    @Environment(NewEventManager.self) private var manager
    
    var imageURLs: [URL] {
        var urls = [URL]()
        guard let selectedSport = manager.selectedSports.first else { return urls }
        for image in selectedSport.images {
            if let url = URL(string: GenerateImageURL(image)) {
                urls.append(url)
            }
        }
        return urls
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Event Image")
                .font(.headline)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button(action: { showImagePicker.toggle() }) {
                        if manager.selectedImage == nil {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 150)
                                .foregroundStyle(Color.gray.opacity(0.2))
                                .overlay {
                                    Image(systemName: "plus")
                                        .foregroundStyle(Color("foreground"))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                }
                        } else {
                            if let image = manager.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "circle.fill")
                                                    .foregroundColor(Color("color-secnd"))
                                                    .padding(.bottom, 5)
                                                    .padding(.trailing, 5)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    
                    
                    ForEach(0..<imageURLs.count, id: \.self) { index in
                        Button(action:{ manager.selectedImageIndex = index }) {
                            KFImage(imageURLs[index])
                                .resizable()
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 100, height: 150)
                                }
                                .loadDiskFileSynchronously()
                                .frame(width: 100, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            if manager.selectedImage == nil {
                                                if manager.selectedImageIndex == index {
                                                    Image(systemName: "circle.fill")
                                                        .foregroundColor(Color("color-secnd"))
                                                        .padding(.bottom, 5)
                                                        .padding(.trailing, 5)
                                                    
                                                } else {
                                                    Image(systemName: "circle")
                                                        .foregroundColor(Color("color-secnd"))
                                                        .padding(.bottom, 5)
                                                        .padding(.trailing, 5)
                                                        .fontWeight(.bold)
                                                }
                                            }
                                        }
                                    }
                                }
                                .onChange(of: manager.selectedImageIndex) { _, newValue in
                                    guard let selectedSport = manager.selectedSports.first else { return }
                                    manager.image = selectedSport.images[newValue]
                                }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showImagePicker, content: {
            MediaPicker(pickerType: .eventImage) { images in
                manager.selectedImage = images.first
            }
        })
    }
}

#Preview {
    EventImagePicker()
        .environment(NewEventManager())
}
