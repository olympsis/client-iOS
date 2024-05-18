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
    @State private var path: [String] = ["picker", "cropper"]
    @StateObject private var viewModel: MediaPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init (pickerType: MediaPickerType) {
        
        self.pickerType = pickerType
        
        var maxSelection = 0
        
        switch pickerType {
        case .newPost:
            maxSelection = 3
        case .profile:
            maxSelection = 1
        case .newAnnouncement:
            maxSelection = 3
        case .newEvent:
            maxSelection = 1
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
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        
                    } label: {
                        Text("Next")
                    }

                }.padding(.horizontal)
                
                VStack {
                    if let image = viewModel.latestSelected {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Select an image")
                    }
                }.frame(minWidth: SCREEN_WIDTH, maxHeight: .infinity)
                
                VStack {
                    switch pickerType {
                    case .newPost, .newAnnouncement:
                        HStack {
                            Spacer()
                            Button(action: { viewModel.selectingMultiple.toggle() }) {
                                viewModel.selectingMultiple ? Image(systemName: "square.stack.3d.down.right.fill") : Image(systemName: "square.stack.3d.down.right")
                            }
                            .padding(.horizontal, 3)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color("background"))
                            }.padding(.horizontal)
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
                    .frame(height: 200)
                }
            }.navigationDestination(for: String.self) { value in
                if value == "cropper" {
                    
                }
            }
        }
    }
}

#Preview {
    MediaPicker(pickerType: .newPost)
}
