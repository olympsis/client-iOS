//
//  MediaPickerViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/17/24.
//

import os
import SwiftUI
import PhotosUI
import Foundation

class MediaPickerViewModel: ObservableObject {
    
    @Published var maxSelection: Int
    @Published var selectionLimit: Int = 1
    @Published var selectingMultiple: Bool = false {
        didSet {
            if selectingMultiple {
                selectionLimit = maxSelection
            } else {
                selectionLimit = 1
            }
        }
    }
    
    @Published var state: LOADING_STATE = .pending
    @Published var latestSelected: UIImage?
    @Published var selectedContent: [PhotosPickerItem] = [] {
        didSet {
            if let lastItem = selectedContent.last {
                loadImage(from: lastItem)
            } else {
                latestSelected = nil
            }
        }
    }

    var log = Logger(subsystem: "com.media_picker.package", category: "media_picker_view_model")
    
    init (
        maxSelection: Int
    ) {
        self.maxSelection = maxSelection
    }
    
    func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let d = data else {
                        return
                    }
                    self.latestSelected = UIImage(data: d)
                case .failure(let error):
                    self.log.error("Error loading image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadContents() async -> [UIImage] {
        state = .loading
        var images = [UIImage]()
        do {
            for content in selectedContent {
                if let data = try await content.loadTransferable(type: Data.self) {
                    if let img = UIImage(data: data) {
                        images.append(img)
                    }
                }
            }
        } catch {
            state = .failure
            self.log.error("Failed to load images: \(error.localizedDescription)")
        }
        state = .success
        return images
    }
}
