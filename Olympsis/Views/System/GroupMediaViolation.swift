//
//  GroupMediaViolation.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/28/24.
//

import SwiftUI

struct GroupMediaViolation: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                }
                
                Spacer()
            }
            .padding(.all)
            
            ScrollView {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .imageScale(.large)
                    .padding(.top)
                
                Text("Your Group violates our Community Standards")
                    .font(.title2)
                    .padding(.top)
                    .bold()
                
                Text("Your group's logo/banner may contain content that we consider innapropriate or harmful to others on Olympsis.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("We have these standards to do the best that we can to prevent harm on our platform and to give you the best experience that we can on your health journey.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("Repeatedly violating our Community Standards will lead to further account restrictions and or termination.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("If you disagree with our decision please make a report in your profile setttings and or contact us at contact@olympsis.com.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("We want to be better and make Olympsis an enjoyable experience for you.")
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            .padding(.horizontal, 5)
        }.presentationDragIndicator(.visible)
    }
}

#Preview {
    GroupMediaViolation()
}
