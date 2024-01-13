//
//  LoadingButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import SwiftUI

struct LoadingButton: View {
    
    @State var text: String
    @State var image: Image?
    @State var width: CGFloat = 150
    @State var height: CGFloat = 40
    @State var color: Color = Color("color-prime")
    @Binding var status: LOADING_STATE
    
    var body: some View {
        if (self.status == .loading) {
            ZStack {
                Rectangle()
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                ProgressView()
            }
        } else if (self.status == .pending) {
            if (image == nil) {
                ZStack{
                    Rectangle()
                        .foregroundColor(color)
                        .frame(width: width, height: height)
                    Text(text)
                        .font(.caption)
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
            } else {
                ZStack {
                    Rectangle()
                        .foregroundColor(color)
                        .frame(width: width, height: height)
                    image
                        .foregroundStyle(.white)
                }
            }
        } else if (self.status == .success) {
            ZStack {
                Rectangle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(color)
                Image(systemName: "checkmark")
                    .imageScale(.large)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
               
        } else if (self.status == .failure) {
            ZStack {
                 Rectangle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(color)
                Image(systemName: "xmark")
                    .imageScale(.large)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
    }
}

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        LoadingButton(text: "Save Changes", image: Image(systemName: "paperplane.fill"), width: 40, status: .constant(.pending))
    }
}
