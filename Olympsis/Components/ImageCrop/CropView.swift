//
//  CropView.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/16/24.
//

import UIKit
import SwiftUI
import Foundation


struct CropView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CropViewModel
    
    private let image: UIImage
    private let configuration: CropConfiguration
    private let onComplete: (UIImage?) -> Void
    
    private let SCREEN_WIDTH = UIScreen.main.bounds.width
    private let SCREEN_HEIGHT = UIScreen.main.bounds.height

    init(
        image: UIImage,
        configuration: CropConfiguration,
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self.image = image
        self.configuration = configuration
        self.onComplete = onComplete
        
        _viewModel = StateObject(
            wrappedValue: CropViewModel(
                maxMagnificationScale: configuration.maxMagnificationScale,
                configuration: configuration
            )
        )
    }

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                let sensitivity: CGFloat = 0.1 * configuration.zoomSensitivity
                let scaledValue = (value.magnitude - 1) * sensitivity + 1

                let maxScaleValues = viewModel.calculateMagnificationGestureMaxValues()
                let newScale = min(max(scaledValue * viewModel.scale, maxScaleValues.0), maxScaleValues.1)

                let maxOffsetPoint = viewModel.calculateDragGestureMax()
                let newX = min(max(viewModel.lastOffset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
                let newY = min(max(viewModel.lastOffset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
                let newOffset = CGSize(width: newX, height: newY)
                
                withAnimation {
                    viewModel.scale = newScale
                    viewModel.offset = newOffset
                }
            }
            .onEnded { _ in
                viewModel.lastScale = viewModel.scale
                viewModel.lastOffset = viewModel.offset
            }

        let dragGesture = DragGesture()
            .onChanged { value in
                let maxOffsetPoint = viewModel.calculateDragGestureMax()
                let newX = min(
                    max(value.translation.width + viewModel.lastOffset.width, -maxOffsetPoint.x),
                    maxOffsetPoint.x
                )
                let newY = min(
                    max(value.translation.height + viewModel.lastOffset.height, -maxOffsetPoint.y),
                    maxOffsetPoint.y
                )
                viewModel.offset = CGSize(width: newX, height: newY)
            }
            .onEnded { _ in
                viewModel.lastOffset = viewModel.offset
            }

        let rotationGesture = RotationGesture()
            .onChanged { value in
                viewModel.angle = value
            }
            .onEnded { _ in
                viewModel.lastAngle = viewModel.angle
            }

        VStack {
            // MARK: - Instructions
            Text(String(localized: "Move and scale", table: "General"))
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .padding(.top, 30)
                .zIndex(1)

            
            
            // MARK: - Image Cropping
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(viewModel.angle)
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .opacity(0.3)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    viewModel.imageSizeInView = geometry.size
                                }
                        }
                    )

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .rotationEffect(viewModel.angle)
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .mask(
                        MaskShapeView(configuration: configuration)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .simultaneousGesture(magnificationGesture)
            .simultaneousGesture(dragGesture)
            .simultaneousGesture(configuration.rotateImage ? rotationGesture : nil)

            // MARK: - Action Buttons
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "Cancel", table: "General"))
                }
                .foregroundColor(.white)

                Spacer()

                Button {
                    onComplete(cropImage())
                    dismiss()
                } label: {
                    Text(String(localized: "Save", table: "General"))
                }
                .foregroundColor(.white)
            }.padding()
        }
        .background(.black)
    }

    private func cropImage() -> UIImage? {
        var editedImage: UIImage = image
        if configuration.rotateImage {
            if let rotatedImage: UIImage = viewModel.rotate(
                editedImage,
                viewModel.lastAngle
            ) {
                editedImage = rotatedImage
            }
        }
        return viewModel.cropImage(editedImage)
    }

    private struct MaskShapeView: View {
        
        let configuration: CropConfiguration
        
        var body: some View {
            Group {
                switch configuration.maskShape {
                case .circle:
                    Circle()
                        .frame(width: configuration.screenWidth, height: configuration.screenWidth)
                        // We use the screen width here since we want a circle not an oval

                case .square:
                    Rectangle()
                        .frame(width: configuration.screenWidth, height: configuration.screenWidth)
                        // We use the screen width here since we want a square and not a rectangle
                    
                case .rectangle:
                    Rectangle()
                        .frame(width: configuration.screenWidth, height: configuration.screenWidth * (566.0 / 1080.0)) // resolution 1080x566 TODO: - I need to make this more dynamic
                        // We multiply by the aspect ratio that we want for a rectangle image
                }
            }
        }
    }
}

#Preview {
    CropView(image: UIImage(named: "volleyball-1")!, configuration: .init(rotateImage: false, maskShape: .rectangle), onComplete: { _ in })
}
