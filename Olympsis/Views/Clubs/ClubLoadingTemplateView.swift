//
//  ClubLoadingTemplateView.swift
//  Olympsis
//
//  Created by Joel Joseph on 1/14/23.
//

import SwiftUI

struct ClubLoadingTemplateView: View {
    @State private var templates = ["IMAGE", "IMAGE", "IMAGE", "NO IMAGE", "IMAGE", "NO IMAGE", "IMAGE", "NO IMAGE"]
    var body: some View {
        ScrollView {
            VStack {
                ForEach(templates, id: \.self){ t in
                    PostTemplateView(type: t)
                        .padding(.bottom)
                }
            }
        }.padding(.top)
    }
}

struct ClubLoadingTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        ClubLoadingTemplateView()
    }
}
