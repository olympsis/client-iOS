//
//  LoadingButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import SwiftUI

struct LoadingButton: View {
    
    @State var text: String?
    @State var image: Image?
    @State var width: CGFloat = 150
    @State var height: CGFloat = 40
    @State var color: Color = Color.Brand.primary
    
    @Binding var status: LOADING_STATE
    
    var body: some View {
        Group {
            if #available (iOS 26.0, *) {
                if (self.status == .loading) {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                            .frame(width: height, height: height)
                            .glassEffect(.regular.tint(Color.Brand.primary), in: .rect(cornerRadius: 10))
                        Spacer()
                    }
                } else if (self.status == .pending) {
                    if (image == nil) {
                        HStack{
                            Spacer()
                            Text(text ?? "")
                                .italic()
                                .font(.title3)
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Spacer()
                        }
                        .frame(minWidth: width)
                        .frame(height: height)
                        .glassEffect(.regular.tint(color).interactive())
                    } else {
                        image
                            .foregroundStyle(.white)
                            .frame(width: height, height: height)
                            .glassEffect(.regular.tint(color).interactive(), in: .rect(cornerRadius: 10))
                    }
                } else if (self.status == .success) {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: height, height: height)
                            .glassEffect(.regular.tint(.green), in: .rect(cornerRadius: 10))
                        Spacer()
                    }
                       
                } else if (self.status == .failure) {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: height, height: height)
                            .glassEffect(.regular.tint(.red), in: .rect(cornerRadius: 10))
                        Spacer()
                    }
                }
            } else {
                if (self.status == .loading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(color)
                            .frame(width: height)
                        ProgressView()
                    }.frame(height: height)
                } else if (self.status == .pending) {
                    if (image == nil) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(color)
                                .frame(minWidth: width)
                            Text(text ?? "")
                                .italic()
                                .font(.title3)
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }.frame(height: height)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(color)
                                .frame(width: width, height: height)
                            image
                                .foregroundStyle(.white)
                        }.frame(height: height)
                    }
                } else if (self.status == .success) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: height)
                            .foregroundColor(color)
                        Image(systemName: "checkmark")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }.frame(height: height)
                       
                } else if (self.status == .failure) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: height)
                            .foregroundColor(.red)
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }.frame(height: height)
                }
            }
        }
    }
}

#Preview("Icon Pending") {
    LoadingButton(text: "Save Changes", image: Image(systemName: "paperplane.fill"), width: 40, status: .constant(.pending))
}

#Preview("Text Pending") {
    LoadingButton(text: "Create Event", width: 150, height: 50, status: .constant(.pending))
}

#Preview("Loading") {
    LoadingButton(text: "Save Changes", image: Image(systemName: "paperplane.fill"), width: 40, status: .constant(.loading))
}

#Preview("Success") {
    LoadingButton(text: "Save Changes", image: Image(systemName: "paperplane.fill"), width: 40, status: .constant(.success))
}

#Preview("Failure") {
    LoadingButton(text: "Save Changes", image: Image(systemName: "paperplane.fill"), width: 40, status: .constant(.failure))
}
