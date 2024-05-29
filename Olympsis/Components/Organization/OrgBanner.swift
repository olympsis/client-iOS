//
//  OrgBanner.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/27/24.
//

import SwiftUI
import Kingfisher

struct OrgBanner: View {
    
    var logo: URL? {
        guard let logo = organization.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    var banner: URL? {
        guard let banner = organization.banner else {
            return nil
        }
        return URL(string: GenerateImageURL(banner))
    }
    
    @EnvironmentObject private var organization: Organization
    
    var body: some View {
        ZStack(alignment: .top) {
            if let bannerURL = banner {
                KFImage(bannerURL)
                    .resizable()
                    .frame(width: SCREEN_WIDTH, height: 250)
            } else {
                Rectangle()
                    .foregroundStyle(.gray)
                    .frame(width: SCREEN_WIDTH, height: 250)
                    .overlay {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(Color("background"))
                            .imageScale(.large)
                    }
            }
            
            VStack {
                Spacer()
                if let logoURL = logo {
                    KFImage(logoURL)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .border(Color("background"), width: 3)
                } else {
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.gray)
                        .border(Color("background"), width: 3)
                        .overlay {
                            Image(systemName: "building.fill")
                                .imageScale(.large)
                                .foregroundStyle(Color("background"))
                        }
                }
            }
        }
        .frame(height: 300)
    }
}

#Preview {
    OrgBanner()
        .environmentObject(ORGANIZATIONS[1])
}
