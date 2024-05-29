//
//  Privacy Policy.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/31/24.
//

import SwiftUI

struct PrivacyPolicy: View {
    var body: some View {
        ScrollView {
            Text("At Olympsis, we take your privacy seriously. This Privacy Policy outlines how we collect, use, and protect the information you provide to us.")
                .padding(.top)
                .padding(.horizontal)
            
            GroupBox {
                Text("""
                    We may collect various types of information from you, including:

                    1. Personal Information: We collect basic personal information such as your name, email address, and other contact details when you create an account or interact with our services.

                    2. Usage Data: We collect data about how you interact with our platform, including the features you use, the content you access, and your preferences.

                    3. Location Data: With your permission, we may collect your location data to provide you with location-aware content, such as local events and activities.
                """)
            } label: {
                Label("Information we collect", systemImage: "note.text")
            }
            
            GroupBox {
                Text("""
                    We use the information we collect for the following purposes:

                    1. To provide and improve our services: We use your information to operate, maintain, and enhance the features and functionality of our platform.

                    2. Personalization: We may use your usage data and preferences to provide you with personalized recommendations and tailored content.

                    3. Location-based Services: With your consent, we may use your location data to show you relevant local events, activities, and other location-aware content.

                    4. Internal Analysis: We may analyze the collective data we collect to understand usage patterns, improve our services, and develop new features.
                """)
            } label: {
                Label("How We Use Your Information", systemImage: "person")
            }
            
            GroupBox {
                Text("""
                    We take steps to ensure that the data we collect is not directly linked to your individual identity. If you choose to delete your account, the data associated with your account will be anonymized and disassociated from your personal information. This anonymized data may be retained and used for internal purposes, such as improving our services and providing better recommendations to other users.
                """)
            } label: {
                Label("Data Retention and Anonymization", systemImage: "person.slash")
            }
            
            GroupBox {
                Text("""
                    We do not sell, trade, or rent your personal information to third parties. However, we may share anonymized and aggregated data with trusted partners for analytical purposes or to improve our services.
                """)
            } label: {
                Label("Data Sharing and Disclosure", systemImage: "arrowshape.left.arrowshape.right")
            }
            
            GroupBox {
                Text("""
                    You have the right to access, modify, or delete the personal information we have collected about you. You can also choose to opt-out of certain data collection practices, such as location tracking, by adjusting your account settings.
                """)
            } label: {
                Label("Your Rights and Choices", systemImage: "hand.point.up.left")
            }
            
            GroupBox {
                Text("""
                    We implement reasonable technical and organizational measures to protect your information from unauthorized access, disclosure, alteration, or destruction.
                """)
            } label: {
                Label("Security", systemImage: "lock")
            }
            
            GroupBox {
                Text("""
                    We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements. We will notify you of any significant changes and provide you with the opportunity to review the updated policy.
                """)
            } label: {
                Label("Changes to this Policy", systemImage: "arrow.circlepath")
            }
            
            Text("If you have any questions or concerns about our Privacy Policy, please contact us at [contact@olympsis.com].")
                .padding(.horizontal)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicy()
    }
}
