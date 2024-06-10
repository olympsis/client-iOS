//
//  PhotosPickerViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/16/24.
//

import os
import SwiftUI
import PhotosUI
import Foundation

class PhotoPickerViewModel: ObservableObject {
    
    @Published var selectedPhoto: UIImage?
    @Published var showImageCropper: Bool = false
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                loadImage(from: imageSelection)
            }
        }
    }
    
    var log = Logger(subsystem: "com.olympsis.client", category: "viewModel")
    
    func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let d = data else {
                        return
                    }
                    self.selectedPhoto = UIImage(data: d)
                    self.showImageCropper.toggle()
                case .failure(let error):
                    self.log.error("Error loading image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}
