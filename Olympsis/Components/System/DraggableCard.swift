//
//  DraggableCard.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/13/25.
//

import SwiftUI

enum DraggableDetent: Equatable {
    case height(CGFloat)
    case fraction(CGFloat)
    case custom(CGFloat)
    
    func height(in screenHeight: CGFloat) -> CGFloat {
        switch self {
        case .height(let height):
            return height
        case .fraction(let fraction):
            return screenHeight * fraction
        case .custom(let height):
            return height
        }
    }
}

struct DraggableCard<Content: View>: View {
    let content: Content
    let detents: [DraggableDetent]
    
    // Height states
    private let minHeight: CGFloat = 60
    private let middleHeight: CGFloat = 250
    private let maxHeight: CGFloat = UIScreen.main.bounds.height / 2
    
    @State private var currentHeight: CGFloat
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragPosition: CGFloat?
    @GestureState private var isDragging = false
    
    init(detents: [DraggableDetent] = [.height(60), .height(250), .fraction(0.5)],
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.detents = detents
        
        let smallestDetent = detents.map { $0.height(in: UIScreen.main.bounds.height) }.min() ?? 60
        self._currentHeight = State(initialValue: smallestDetent)
    }
    
    private func nearestDetent(for height: CGFloat, in geometry: GeometryProxy, velocity: CGFloat = 0) -> CGFloat {
        let screenHeight = geometry.size.height
        let detentHeights = detents.map { $0.height(in: screenHeight) }.sorted()
        
        if abs(velocity) > 300 {
            if velocity > 0 { // Moving down
                return detentHeights.last { $0 < height } ?? detentHeights[0]
            } else { // Moving up
                return detentHeights.first { $0 > height } ?? detentHeights.last ?? height
            }
        }
        
        return detentHeights.min(by: { abs($0 - height) < abs($1 - height) }) ?? height
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    content
                        .padding(.top, 8)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 4)
                                .cornerRadius(2)
                                .padding(.top, 15)
                                .padding(.bottom, 4)
                        }
                }
                .frame(maxWidth: .infinity)
                .frame(height: currentHeight)
                .gesture(
                    DragGesture(minimumDistance: 5, coordinateSpace: .global)
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            let delta = value.location.y - (lastDragPosition ?? value.location.y)
                            lastDragPosition = value.location.y
                            
                            let heights = detents.map { $0.height(in: geometry.size.height) }
                            let minHeight = heights.min() ?? 0
                            let maxHeight = heights.max() ?? geometry.size.height
                            
                            // Apply resistance when dragging beyond bounds
                            if currentHeight <= minHeight && delta > 0 {
                                dragOffset = delta * 0.2
                            } else if currentHeight >= maxHeight && delta < 0 {
                                dragOffset = delta * 0.2
                            } else {
                                dragOffset = delta
                            }
                            
                            currentHeight = max(minHeight, min(maxHeight, currentHeight - dragOffset))
                        }
                        .onEnded { value in
                            lastDragPosition = nil
                            
                            let velocity = value.predictedEndLocation.y - value.location.y
                            let targetHeight = nearestDetent(for: currentHeight, in: geometry, velocity: velocity)
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)) {
                                dragOffset = 0
                                currentHeight = targetHeight
                            }
                        }
                )
                .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.7), value: isDragging)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
