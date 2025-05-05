//
//  ImageSaver.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/21/24.
//

import SwiftUI
import Foundation

class ImageSaver: NSObject, ObservableObject {
    
    @Published var isSaved = false
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            isSaved = true
        }
    }
}
