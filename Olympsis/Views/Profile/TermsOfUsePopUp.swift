//
//  TermsOfUsePopUp.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/13/24.
//

import SwiftUI

struct TermsOfUsePopUp: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Review and Agree")
                    .fontWeight(.medium)
                Spacer()
            }
            ScrollViewReader { scrollView in
                ScrollView {
                    HStack {
                        Text("Terms of Use")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }.padding(.horizontal)
                    
                    VStack {
                        Text("""
                        Welcome to Olympsis! These Terms of Use govern your use of our Service, which includes our mobile apps, websites, and software (collectively, the \"Olympsis Service\" or \"Service\"). By accessing or using our Service, you agree to be bound by these Terms and our Privacy Policy.
                        """).padding(.horizontal)
                        
                        GroupBox {
                            Text("""
                            You must be at least 13 years old to use the Olympsis Service. If you are under 18 years old, you represent that you have your parent or guardian's permission to use the Service.
                            """)
                        } label: {
                            Text("1 - Who Can Use the Service")
                        }
                        
                        GroupBox {
                            Text("""
                            Olympsis grants you a limited, revocable, non-exclusive, non-transferable license to use the Service for your personal, non-commercial purposes only. You agree not to do any of the following:
                            
                            - Use the Service for any illegal or unauthorized purpose.
                            
                            - Violate any laws or third-party rights.
                            
                            - Sell, license, rent, modify, distribute, copy, reproduce, transmit, publicly display, publicly perform, publish, adapt, edit, create derivative works from, or exploit the Service.
                            
                            - Reverse engineer any aspect of the Service.
                            
                            - Your Content must not reflect nudity and should not be sexual in nature.
                            
                            - You will be accountable for any activity taking place under your account.
                            
                            - International users must abide by all applicable local laws regarding online behavior and acceptable content.
                            
                            - You are solely responsible for all data, images, links, and other content that you transmit, publish, and display on the platform.
                            
                            - You are not permitted to access Olympsis' private APIs in any way other than through the official Olympsis application.
                            """)
                        } label: {
                            Text("2 - Your Use of the Service")
                        }
                        
                        GroupBox {
                            Text("""
                            Our Service may contain information, text, links, graphics, photos, videos, or other materials ("Content"), including Content posted by you and others. You retain ownership of any intellectual property rights you hold in the Content you post. However, by posting Content, you grant Olympsis a worldwide, royalty-free, sublicensable, and transferable license to host, store, use, display, reproduce, modify, adapt, edit, publish, and distribute that Content.
                            
                            You are solely responsible for the Content you post and its consequences. Your Content must comply with our Content Policy prohibiting nudity, sexually explicit or obscene material. Olympsis has the right (but not the obligation) to remove or edit any Content that violates these Terms at any time.
                            """)
                        } label: {
                            Text("3 - Content on the Service")
                        }

                        
                        GroupBox {
                            Text("""
                            The Service may provide access to third-party services, websites, information, advertisements, or other materials. Olympsis does not endorse or assume any responsibility for these third-party materials or services.
                            """)
                        } label: {
                            Text("4 - Third-Party Content and Services")
                        }
                        
                        
                        GroupBox {
                            Text("""
                            Olympsis reserves the right to modify or discontinue the Service at any time without notice.
                            """)
                        } label: {
                            Text("5 - Modifications to the Service")
                        }
                        
                        GroupBox {
                            Text("""
                            We respond to copyright violation notices in accordance with the Digital Millennium Copyright Act. If you believe any Content infringes on your copyrights, please provide a written notice to our DMCA agent with the required information.
                            """)
                        } label: {
                            Text("6 - Copyright Infringement and DMCA Policy")
                        }
                        
                        GroupBox {
                            Text("""
                            YOUR USE OF THE SERVICE IS AT YOUR OWN RISK. THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE." OLYMPSIS MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
                            """)
                        } label: {
                            Text("7 - Disclaimers")
                        }
                        
                        GroupBox {
                            Text("""
                            TO THE FULLEST EXTENT PERMITTED BY LAW, IN NO EVENT SHALL OLYMPSIS BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL, CONSEQUENTIAL, EXEMPLARY, OR PUNITIVE DAMAGES ARISING FROM OR RELATED TO YOUR USE OF THE SERVICE.
                            """)
                        } label: {
                            Text("8 - Limitation of Liability")
                        }
                        
                        GroupBox {
                            Text("""
                            Olympsis may update these Terms of Use from time to time. Your continued use of the Service after any modifications constitutes your acceptance of the new Terms.
                            """)
                        } label: {
                            Text("9 - Changes to Terms of Use")
                        }
                        
                        GroupBox {
                            Text("""
                            If you have any questions or concerns about these Terms, please contact us at [contact@olympsis.com].
                            """)
                        } label: {
                            Text("10 - Contact Us")
                        }
                        
                    }.padding(.top, 5)
                }
            }
            HStack {
                Spacer()
                Button(action: {}) {
                    SimpleButtonLabel(text: "Next")
                }
                Spacer()
            }
        }
    }
}

#Preview {
    TermsOfUsePopUp()
}
