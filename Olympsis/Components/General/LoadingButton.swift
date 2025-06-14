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
            if (self.status == .loading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(color)
                        .frame(width: 40)
                    ProgressView()
                }.frame(height: 40)
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
                        .frame(width: 40)
                        .foregroundColor(color)
                    Image(systemName: "checkmark")
                        .imageScale(.large)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }.frame(height: 40)
                   
            } else if (self.status == .failure) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40)
                        .foregroundColor(color)
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }.frame(height: 40)
            }
        }
    }
}

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        LoadingButton(text: "Save Changes", image: Image(systemName: "paperplane.fill"), width: 40, status: .constant(.pending))
    }
}
