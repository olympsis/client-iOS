//
//  OrgLogo.swift
//  Olympsis
//
//  Created by Joel Joseph on 5/27/24.
//

import SwiftUI
import Kingfisher

struct OrgLogo: View {
    
    var organization: Organization
    var logoURL: URL? {
        guard let logo = organization.logo else {
            return nil
        }
        return URL(string: GenerateImageURL(logo))
    }
    
    var body: some View {
        if let url = logoURL {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100, alignment: .center)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 100, height: 100)
                .foregroundStyle(.gray)
                .opacity(0.5)
                .overlay {
                    Image(systemName: "building.fill")
                        .foregroundStyle(Color("foreground"))
                        .imageScale(.large)
                }
        }
    }
}

#Preview {
    OrgLogo(organization: ORGANIZATIONS[0])
}
