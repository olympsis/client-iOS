//
//  MediaPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/17/24.
//

import SwiftUI
import PhotosUI

struct MediaPicker: View {
    
    var pickerType: MediaPickerType
    let onComplete: ([UIImage]) -> Void
    
    @State var maskShape: CropMaskShape = .square
    @State private var path = NavigationPath()
    @State private var croppedImages: [UIImage] = []
    @StateObject private var viewModel: MediaPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init (
        pickerType: MediaPickerType,
        onComplete: @escaping ([UIImage]) -> Void
    ) {
        
        self.pickerType = pickerType
        self.onComplete = onComplete
        
        var maxSelection = 0
        
        switch pickerType {
        case .newPost:
            maxSelection = 3
            maskShape = .square
        case .profile:
            maxSelection = 1
            maskShape = .circle
        case .newAnnouncement:
            maxSelection = 3
            maskShape = .square
        case .newEvent:
            maxSelection = 1
            maskShape = .square
        case .other:
            maxSelection = 1
            maskShape = .landscape
        case .eventImage:
            maxSelection = 1
            maskShape = .portrait
        }
        
        _viewModel = StateObject(wrappedValue:
            MediaPickerViewModel(
                maxSelection: maxSelection
            )
        )
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                    }
                    
                    Spacer()
                    
                    switch pickerType {
                    case .newPost:
                        Text(MediaPickerType.newPost.rawValue)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    case .profile:
                        Text(MediaPickerType.profile.rawValue)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    case .newAnnouncement:
                        Text(MediaPickerType.newAnnouncement.rawValue)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    case .newEvent:
                        Text(MediaPickerType.newEvent.rawValue)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    case .other:
                        Text("Photo")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    case .eventImage:
                        Text(MediaPickerType.eventImage.rawValue)
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            if (viewModel.selectedContent.count > 0) {
                                await viewModel.loadContents()
                                path.append("cropper")
                            }
                        }
                    }) {
                        switch viewModel.state {
                        case .pending:
                            Text("Next")
                        case .loading:
                            ProgressView()
                        case .success:
                            Text("Next")
                        case .failure:
                            Text("Next")
                        }
                    }

                }
                .padding(.horizontal)
                
                VStack {
                    if let image = viewModel.latestSelected {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        if (viewModel.selectingMultiple) {
                            Text("Select up to 3 images")
                        } else {
                            Text("Select an image")
                        }
                    }
                }
                .frame(minWidth: SCREEN_WIDTH, maxHeight: .infinity)
                
                VStack {
                    switch pickerType {
                    case .newPost, .newAnnouncement:
                        HStack {
                            Spacer()
                            Button(action: {
                                if maskShape == CropMaskShape.square {
                                    maskShape = CropMaskShape.portrait
                                } else {
                                    maskShape = .square
                                }
                            }) {
                                if maskShape == CropMaskShape.square {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: 12, height: 17)
                                } else {
                                    Image(systemName: "square.fill")
                                        .resizable()
                                        .frame(width: 12, height: 12)

                                }
                            }
                            .padding(.horizontal, 5)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color(Color.Background.secondary))
                                    .frame(width: 27, height: 25)
                            }
                            
                            Button(action: { viewModel.selectingMultiple.toggle() }) {
                                viewModel.selectingMultiple ? Image(systemName: "square.stack.3d.down.right.fill") : Image(systemName: "square.stack.3d.down.right")
                            }
                            .padding(.horizontal, 3)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color(Color.Background.secondary))
                            }
                            .padding(.horizontal)
                        }
                    default:
                        EmptyView()
                    }
                    PhotosPicker(
                        selection: $viewModel.selectedContent,
                        maxSelectionCount: viewModel.selectionLimit,
                        selectionBehavior: .continuous,
                        matching: .images,
                        preferredItemEncoding: .current,
                        photoLibrary: .shared()) {
                        EmptyView()
                    }
                    .photosPickerStyle(.inline)
                    .ignoresSafeArea()
                    .photosPickerDisabledCapabilities(.selectionActions)
                    .photosPickerAccessoryVisibility(.hidden, edges: .all)
                    .frame(height: 250)
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "cropper":
                    if viewModel.selectedImages.count > 0 {
                        CropView(images: viewModel.selectedImages, configuration: .init(rotateImage: false, maskShape: maskShape)) { images in
                            croppedImages = images
                            onComplete(croppedImages)
                            dismiss()
                        }.frame(height: SCREEN_HEIGHT)
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    MediaPicker(pickerType: .newPost, onComplete: { _ in })
}
