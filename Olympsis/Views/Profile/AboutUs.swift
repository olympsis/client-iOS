//
//  AboutUs.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/24.
//

import SwiftUI

struct AboutUs: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            HStack {
                Text("About Olympsis")
                    .padding(.all)
                    .font(.title3)
                    .bold()
                Spacer()
            }
            Text("""
            At Olympsis, we are a small but passionate company committed to fostering a vibrant community of athletes and sports enthusiasts. Our mission is to bring people together through the love of sports and physical activity.
            
            We believe that sports have the power to unite people, promote healthy lifestyles, and create lasting bonds of friendship and camaraderie. Whether you're a seasoned athlete or just starting your fitness journey, Olympsis provides a platform for you to connect with like-minded individuals, organize events, and discover new sports and activities.
            
            Our dedicated team works tirelessly to deliver an amazing experience for our users. We understand the importance of having a reliable and user-friendly platform that makes it easy to find and join events, connect with others, and stay motivated on your fitness journey.
            
            While we may be a small company, we are driven by a big dream – to create a world where sports bring people together, promote inclusivity, and foster a sense of community. We are committed to constantly improving our platform, listening to your feedback, and introducing new features that enhance your experience.
            
            Join us on this exciting journey, and let's get out there and play together!
            """)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutUs()
    }
}
