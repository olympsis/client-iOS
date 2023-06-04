//
//  ClubLoadingTemplateView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/14/23.
//

import SwiftUI

struct ClubLoadingTemplateView: View {
    var body: some View {
        ScrollView {
            VStack {
                PostTemplateView(type: "IMAGE")
                PostTemplateView(type: "IMAGE")
                PostTemplateView(type: "IMAGE")
                PostTemplateView(type: "IMAGE")
            }
        }.padding(.top)
    }
}

struct ClubLoadingTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        ClubLoadingTemplateView()
    }
}
