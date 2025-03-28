//
//  OrgListItemMedia.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/25.
//

import SwiftUI
import Kingfisher

struct OrgListItemMedia: View {
    
    var org: Organization
    var logoURL: URL? {
        guard let logo = org.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    var bannerURL: URL? {
        guard let banner = org.banner else {
            return nil
        }
        return URL(string: GenerateImageURL(banner))
    }
    
    var body: some View {
        KFImage(bannerURL)
            .placeholder {
                Rectangle()
                    .foregroundStyle(Color.Background.secondary)
                    .overlay(alignment: .center) {
                        Image(systemName: "photo")
                            .imageScale(.large)
                    }
            }
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .overlay(alignment: .topLeading) {
                KFImage(logoURL)
                    .placeholder {
                        Rectangle()
                            .foregroundStyle(Color.Background.tertiary)
                            .overlay(alignment: .center) {
                                Image(systemName: "building.fill")
                                    .imageScale(.large)
                            }
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(width: 80, height: 80)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.thinMaterial, lineWidth: 5)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
    }
}

#Preview {
    OrgListItemMedia(org: ORGANIZATIONS[0])
}
