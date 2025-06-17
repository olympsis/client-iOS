//
//  EndUserLicenseAgreement.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/13/24.
//

import SwiftUI

struct EndUserLicenseAgreement: View {
    
    @State private var showAlert: Bool = false
    @State private var status: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    
    func AcceptEULA() async {
        status = .loading
        let update = UserDao(acceptedEULA: true)
        guard let user = await session.userObserver.UpdateUserData(update: update) else {
            status = .pending
            showAlert.toggle()
            return
        }
        session.user = user
        status = .success
        dismiss()
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Text("End User License Agreement")
                    .font(.title)
            }.padding()
            ScrollView {
                
                Text("""
                This document is your guide to using the Olympsis platform. By using Olympsis, you agree to follow the rules outlined here, which help keep our community safe, respectful, and fun for everyone. This agreement covers how you should behave on Olympsis, what kind of content you can post, how we use your information, and other important details.
                """).padding(.horizontal)
                    .multilineTextAlignment(.center)
                
                GroupBox {
                    Text("""
                        By accessing or using the Olympsis platform, which includes any associated websites, applications, services, and tools (collectively, "Olympsis"), you agree to comply with and be bound by the terms and conditions of this End User License Agreement ("Agreement"). Please read this Agreement carefully before using Olympsis. If you do not agree to these terms, you must not use our services.
                    """)
                } label: {
                    Text("1. Acceptance of Terms")
                }
                
                GroupBox {
                    Text("""
                        You are solely responsible for your conduct and any data, text, files, information, usernames, images, graphics, photos, profiles, audio and video clips, sounds, musical works, works of authorship, links, and other content or materials (collectively, "Content") that you submit, post, or display on or via Olympsis.
                    """)
                } label: {
                    Text("2. User Conduct and Responsibilities")
                }
                
                GroupBox {
                    Text("""
                        You agree not to engage in any of the following prohibited activities on or through Olympsis:
                        - Harassment: Engaging in harassing, bullying, or threatening behavior towards other users.
                        - Inappropriate Content: Posting or sharing sexually explicit, racy, violent, or otherwise inappropriate material.
                        - Illegal Activities: Conducting or promoting illegal activities.
                        - Impersonation: Impersonating another person or entity or falsely stating or otherwise misrepresenting your affiliation with a person or entity.
                        - Intellectual Property Violation: Posting content that infringes upon any third party’s intellectual property rights.

                    """)
                } label: {
                    Text("3. Prohibited Conduct")
                }
                
                GroupBox {
                    Text("""
                        All Content must comply with the following standards:
                        - Content must be accurate (where it states facts).
                        - Content must be genuinely held (where it states opinions).
                        - Content must comply with applicable law and regulations in any country from which it is posted.
                    """)
                } label: {
                    Text("4. Content Standards")
                }
                
                GroupBox {
                    Text("""
                        Olympsis reserves the right to:
                        - Remove or refuse to post any user content for any or no reason.
                        - Take any action with respect to any user content that we deem necessary or appropriate.
                        - Terminate or suspend your access to all or part of Olympsis for any or no reason, including any violation of this Agreement.

                        We have the right to investigate violations of this Agreement or conduct that affects Olympsis. We may also consult and cooperate with law enforcement authorities to prosecute users who violate the law.

                    """)
                } label: {
                    Text("5. Monitoring and Enforcement")
                }
                
                GroupBox {
                    Text("""
                        If you encounter any Content you find inappropriate or otherwise believe to be in violation of this Agreement, you are encouraged to contact us immediately via our reporting feature or email us at contact@olympsis.com. We are committed to addressing your concerns promptly and appropriately.
                    """)
                } label: {
                    Text("6. Reporting and Grievance Mechanism")
                }
                
                GroupBox {
                    Text("""
                        Olympsis is provided on an "as is" and "as available" basis. We do not guarantee that Olympsis will always be safe, secure, or error-free, or that Olympsis will always function without disruptions, delays, or imperfections.
                    """)
                } label: {
                    Text("7. Disclaimers and Limitation of Liability")
                }
                
                GroupBox {
                    Text("""
                        This Agreement constitutes the entire agreement between you and Olympsis concerning your use of the platform. If any provision of this Agreement is deemed invalid by a court of competent jurisdiction, the invalidity of such provision shall not affect the validity of the remaining provisions of this Agreement.
                    """)
                } label: {
                    Text("8. General Terms")
                }
                
                GroupBox {
                    Text("""
                        We reserve the right to modify or replace these terms at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.
                    """)
                } label: {
                    Text("9. Amendments")
                }
                
                GroupBox {
                    Text("""
                        a. Collection and Use of Information
                        By using Olympsis, you agree that we may collect, store, and use information about you in accordance with our Privacy Policy. The information collected can include personal data provided during registration and usage details of our services.
                        b. Internal Use of Data
                        We may use your information internally to:
                        Improve our services and user experience.
                        Conduct research and analysis to better understand the needs of our users.
                        Develop new features and services.
                        Manage day-to-day business needs.
                        c. Sharing of Information
                        Your information will not be shared with third parties, except:
                        As required by law.
                        With your consent.
                        With service providers who assist us in our operations under confidentiality agreements.
                        d. Security
                        We are committed to ensuring the security of your personal information. We take reasonable precautions to protect your data from loss, misuse, unauthorized access, disclosure, alteration, or destruction.
                        e. Privacy Policy
                        For more detailed information on the collection, use, and sharing of your personal data, please refer to our Privacy Policy.

                        This section ensures transparency about data usage practices on Olympsis and aligns with general best practices for user data handling. Make sure to also have a comprehensive Privacy Policy in place, which should be referenced in your EULA and accessible to users. This will help in building trust with your users and ensure compliance with applicable data protection laws.

                    """)
                } label: {
                    Text("10. Use of Data")
                }
                
                GroupBox {
                    Text("""
                        For questions about this Agreement or the Olympsis platform, please contact contact@olympsis.com.
                    """)
                } label: {
                    Text("11. Contact Us")
                }
                
                Text("""
                    By using Olympsis, you agree to be bound by this Agreement and affirm that you understand and accept the conditions laid out herein.
                    """)
                .padding(.vertical)
                
                Button(action: { Task { await AcceptEULA() }}) {
                    LoadingButton(text: String(localized: "accept", table: "General"), status: $status)
                }.padding(.vertical)
                
                Button(action: { dismiss() }) {
                    Text(String(localized: "no-thanks", table: "General"))
                        .font(.callout)
                }.foregroundStyle(.gray)
                    
            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Unexpected"), 
                    message: Text("Failed to accept EULA"),
                    dismissButton: .default(Text("Dismiss"))
                )
            }
        }
    }
}

#Preview {
    EndUserLicenseAgreement()
        .environment(SessionStore())
}
