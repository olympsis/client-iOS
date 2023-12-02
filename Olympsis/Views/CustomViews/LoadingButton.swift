//
//  LoadingButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 12/17/22.
//

import SwiftUI

struct LoadingButton: View {
    
    @State var text: String
    @State var width: Double
    @Binding var status: LOADING_STATE
    
    var body: some View {
        if self.status == .loading {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("color-prime"))
                    .frame(width: 50, height: 40)
                ProgressView()
            }
        } else if self.status == .pending{
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color("color-prime"))
                    .frame(height: 40)
                Text(text)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
        } else if self.status == .success {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 50, height: 40)
                    .foregroundColor(Color("color-prime"))
                Image(systemName: "checkmark")
                    .imageScale(.large)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
               
        } else if self.status == .failure {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 50, height: 40)
                    .foregroundColor(Color("color-prime"))
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
