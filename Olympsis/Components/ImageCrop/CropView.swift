//
//  CropView.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/16/24.
//

import UIKit
import SwiftUI
import PhotosUI
import Foundation


struct CropView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CropViewModel
    
    private let images: [UIImage]
    private let configuration: CropConfiguration
    private let onComplete: ([UIImage]) -> Void
    
    private let SCREEN_WIDTH = UIScreen.main.bounds.width
    private let SCREEN_HEIGHT = UIScreen.main.bounds.height

    init(
        images: [UIImage],
        configuration: CropConfiguration,
        onComplete: @escaping ([UIImage]) -> Void
    ) {
        self.images = images
        self.configuration = configuration
        self.onComplete = onComplete
        
        _viewModel = StateObject(
            wrappedValue: CropViewModel(
                images: images,
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
                Image(uiImage: images[viewModel.selectedIndex])
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
                                .onChange(of: viewModel.selectedIndex) { _, _ in
                                    viewModel.imageSizeInView = geometry.size
                                }
                        }
                    )
                    

                Image(uiImage: images[viewModel.selectedIndex])
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
        
            // MARK: - Image thumbnails
            HStack {
                ForEach(images.indices, id: \.self) { i in
                    Button(action: { viewModel.selectedIndex = i }) {
                        Image(uiImage: images[i])
                            .resizable()
                            .frame(width: 50, height: 50)
                            .border(Color.white, width: viewModel.selectedIndex == i ? 1 : 0)
                    }
                }
            }.frame(height: 100)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    onComplete(viewModel.cropImages())
                    dismiss()
                }) {
                    Text("Done")
                }
            }
        }
        .background(.black)
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
    CropView(images: [UIImage(named: "volleyball-1")!, UIImage(named: "soccer-1")!, UIImage(named: "tennis-1")!], configuration: .init(rotateImage: false, maskShape: .rectangle), onComplete: { _ in })
}
