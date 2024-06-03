//
//  CropModels.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/16/24.
//

import SwiftUI
import Foundation
import CoreGraphics

/// `CropResolution` is a struct that defines the resolution of your desired output image so that we can calculate the width/height correctly on the cropping view
public struct CropResolution {
    let width: Int
    let height: Int
}

/// `CropMaskShape` is a an enum that helps us keep track of the desired mask shapes
public enum CropMaskShape: CaseIterable {
    case circle, square, rectangle, rectangleV
}

/// `CropConfiguration` is a struct that defines the configuration for cropping behavior.
public struct CropConfiguration {
    
    public let maxMagnificationScale: CGFloat
    public let cropImageCircular: Bool
    public let rotateImage: Bool
    public let zoomSensitivity: CGFloat
    public let maskShape: CropMaskShape
    
    public let screenWidth: CGFloat = UIScreen.main.bounds.width
    public let screenHeight: CGFloat = UIScreen.main.bounds.height

    
    public init(
        maxMagnificationScale: CGFloat = 4.0,
        cropImageCircular: Bool = false,
        rotateImage: Bool = true,
        zoomSensitivity: CGFloat = 1,
        maskShape: CropMaskShape = .square
    ) {
        self.maxMagnificationScale = maxMagnificationScale
        self.cropImageCircular = cropImageCircular
        self.rotateImage = rotateImage
        self.zoomSensitivity = zoomSensitivity
        self.maskShape = maskShape
    }
}

