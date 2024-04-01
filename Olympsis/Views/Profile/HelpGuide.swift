//
//  HelpGuide.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/24.
//

import SwiftUI

struct HelpGuide: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                Text("Help")
                    .font(.title2)
                    .bold()
                Spacer()
            }.padding(.all)
            
            ScrollView {
                
                HStack {
                    Text("Getting Help")
                        .font(.title3)
                        .bold()
                        .padding(.all)
                    Spacer()
                }
                
                Text("At Olympsis, we're committed to providing you with the best possible experience. If you encounter any issues, have questions, or need assistance, we have several channels available to help you.")
                    .padding(.horizontal)
                
                GroupBox {
                    Text("""
                        If you come across a bug or technical issue within the app, you can report it through our dedicated bug report option in the profile settings. Please provide as much detail as possible, including steps to reproduce the issue, screenshots or screen recordings if applicable, and any relevant information about your device and app version. Your detailed reports help us identify and resolve problems more efficiently.
                    """)
                } label: {
                    Text("Bug Reports")
                }
                
                GroupBox {
                    Text("""
                        If you encounter any inappropriate events, posts, or malicious user behavior, you can file reports directly within the app. Simply navigate to the right settings menu and follow the prompts to submit your report. Our team will review and take appropriate action to ensure a safe and positive environment for all users.
                    """)
                } label: {
                    Text("Event, Post, or User Reports")
                }
                
                GroupBox {
                    Text("""
                        For general inquiries, feedback, or if you need to share visual aids like pictures or videos, you can reach out to our support team by emailing contact@olympsis.com. Our dedicated support staff will assist you promptly and professionally.
                    """)
                } label: {
                    Text("Email Support")
                }
                
                GroupBox {
                    Text("""
                        You can also connect with us through our social media channels. Follow us on Twitter, Facebook, and Instagram for updates, announcements, and community engagement. Our social media team is actively monitoring these channels and can provide assistance or redirect your inquiries to the appropriate support channels.
                    """)
                } label: {
                    Text("Social Media")
                }
                
                Text("""
                    We value your feedback and strive to address any concerns or issues you may have. Don't hesitate to reach out to us through any of the available channels, and we'll do our best to help you have a seamless and enjoyable experience with Olympsis.
                """).padding(.horizontal)
            }
        }
    }
}

#Preview {
    HelpGuide()
}
