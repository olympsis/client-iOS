//
//  ErrorNotificationToast.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/8/24.
//

import SwiftUI

struct ErrorNotificationToast: View {
    
    var message: String
    
    var body: some View {
        HStack {
            
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
                .padding(.horizontal)
            
            VStack{
                Text("\(message)")
            }
            .foregroundStyle(Color("foreground"))
            .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 60)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color("background"))
                .padding(.horizontal, 10)
        }
    }
}

#Preview {
    ErrorNotificationToast(message: "Failed to create post")
}
