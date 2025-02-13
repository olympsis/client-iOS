    //
//  EventSharingView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/30/24.
//

import SwiftUI
import Kingfisher

struct EventSharingView: View {
    
    var event: Event
    var venue: Venue
    var method: SHARE_METHOD
    
    @State private var screenshot: UIImage?
    @State private var textColor = Color.white
    @State private var selectedTemplate: Int = 0
    @State private var state: LOADING_STATE = .pending
    
    @StateObject private var imageSaver = ImageSaver()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    
    private var imageURL: URL? {
        guard let link = event.imageURL else {
            return nil
        }
        return generateImageURL(link)
    }
    private var imageView: some View {
        return ZStack {
            KFImage(imageURL)
                .resizable()
                .scaleFactor(1)
                .cropping(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0)))
                .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
            
            VStack {
                switch selectedTemplate {
                case 0:
                    HStack {
                        Text(event.title)
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundStyle(textColor)
                            .padding(.top, 25)
                            
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(formatAbbreviatedTimestamp(event.startTime))
                                .font(.title3)
                                .padding(.bottom, 5)
                                .fontWeight(.regular)
                                .foregroundStyle(textColor)
                            
                            Text(venue.name)
                                .font(.title2)
                                
                                .fontWeight(.bold)
                                .foregroundStyle(textColor)
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.bottom)
                    
                case 1:
                    VStack {
                        Spacer()
                        
                        Text(formatAbbreviatedTimestamp(event.startTime))
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(textColor)
                            .padding(.top, 50)
                        
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.title2)
                                .padding(.bottom, 2)
                                .fontWeight(.regular)
                                .foregroundStyle(textColor)
                            
                            Text(venue.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(textColor)
                        }
                        Spacer()
                    }
                    .padding()
                    .padding(.bottom)
                    
                case 2:
                    VStack {
                        Spacer()
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundStyle(textColor)
                            .multilineTextAlignment(.center)
                        
                        Text(venue.name)
                            .font(.title2)
                            .padding(.top)
                            .padding(.bottom, 2)
                            .foregroundStyle(textColor)
                        
                        Text(formatAbbreviatedTimestamp(event.startTime))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(textColor)
                            
                        Spacer()
                    }
                    .padding()
                case 3:
                    VStack {
                        Spacer()
                        
                        Text(formatTimeFromTimestamp(event.startTime))
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundStyle(textColor)
                            .italic()
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.heavy)
                            .fontWeight(.regular)
                            .padding(.vertical, 10)
                            .foregroundStyle(textColor)
                            .multilineTextAlignment(.center)
                        
                        Text(venue.name)
                            .italic()
                            .font(.title2)
                            .fontWeight(.regular)
                            .foregroundStyle(textColor)
                    }
                    
                    .padding()
                default:
                    EmptyView()
                }
            }.frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
            
            VStack {
                HStack {
                    Spacer()
                    
                    Text("Olympsis")
                        .foregroundStyle(textColor)
                        .textCase(.uppercase)
                        .fontWeight(.black)
                        .italic()
                    
                    Spacer()
                }
                .padding(.top, 10)
                Spacer()
            }.frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
        }
    }
    
    @MainActor
    private func capture() async {
        let renderer = ImageRenderer(content: imageView)
        renderer.scale = displayScale

        if let uiImage = renderer.uiImage {
            screenshot = uiImage
        }
    }
    
    private func openPhotosApp() {
        guard let url = URL(string: "photos-redirect://") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                }
                Spacer()
            }.padding(.horizontal)
            
            imageView
            
            Spacer()
            
            VStack {
                
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await capture()
                        }
                    }) {
                        LoadingButton(text: "Share", width: 70, status: $state)
                    }
                    .padding(.trailing)
                }
                
                ColorPicker(selection: $textColor) {
                    EmptyView()
                }.padding(.all)
                
                HStack {
                    ForEach(0..<4, id: \.self) { i in
                        EventSharingTemplateView(template: i)
                            .overlay {
                                if selectedTemplate == i {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.colorPrime, lineWidth: 2)
                                }
                            }
                            .onTapGesture {
                                self.selectedTemplate = i
                            }
                    }
                }
            }
        }
        .onChange(of: screenshot, { _, newValue in
            guard let image = newValue else {
                return
            }
            
            switch method {
            case .image:
                imageSaver.writeToPhotoAlbum(image: image)
            case .facebook:
                break
            case .instagram:
                break
            case .x:
                break
            }
        })
        .onChange(of: imageSaver.isSaved, { _, newValue in
            if newValue {
                dismiss()
                openPhotosApp()
            }
        })
    }
}

#Preview {
    EventSharingView(event: EVENTS[0], venue: FIELDS[0], method: .image)
}
