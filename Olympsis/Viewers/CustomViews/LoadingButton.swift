//
//  LoadingButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import SwiftUI

struct LoadingButton: View {
    
    @State var text: String
    @State var width: CGFloat = 150
    @State var height: CGFloat = 40
    @State var color: Color = Color("color-prime")
    @Binding var status: LOADING_STATE
    
    var body: some View {
        if self.status == .loading {
            ZStack {
                Rectangle()
                    .foregroundColor(color)
                    .frame(width: 50, height: 40)
                ProgressView()
            }
        } else if self.status == .pending{
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
        } else if self.status == .success {
            ZStack {
                Rectangle()
                    .frame(width: 50, height: 40)
                    .foregroundColor(color)
                Image(systemName: "checkmark")
                    .imageScale(.large)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
               
        } else if self.status == .failure {
            ZStack {
                 Rectangle()
                    .frame(width: 50, height: 40)
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
        LoadingButton(text: "Save Changes", width: 150, status: .constant(.loading))
    }
}
