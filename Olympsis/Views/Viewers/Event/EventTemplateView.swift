//
//  EventTemplateView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/18/22.
//

import SwiftUI

struct EventTemplateView: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 80, height: 80)
                    .padding(.leading)
                    .foregroundColor(.gray)
                    .opacity(0.2)
                VStack(alignment: .leading){
                    Rectangle()
                        .font(.custom("Helvetica-Nue", size: 20))
                        .bold()
                        .frame(width: 200,height: 20)
                        .padding(.top)
                        .foregroundColor(.gray)
                        .opacity(0.2)
                    Rectangle()
                        .font(.custom("Helvetica-Nue", size: 20))
                        .bold()
                        .frame(width: 150,height: 15)
                        .foregroundColor(.gray)
                        .opacity(0.2)
                    
                    HStack {
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                            .foregroundColor(.gray)
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                            .foregroundColor(.gray)
                        Circle()
                            .frame(width: 10)
                            .imageScale(.small)
                            .foregroundColor(.gray)
                    }.opacity(0.2)
                    
                    Spacer()
                }
                Spacer()
                VStack (alignment: .trailing){
                    Rectangle()
                        .frame(width: 80,height: 15)
                        .opacity(0.2)
                        .padding(.bottom)
                        .foregroundColor(.gray)
                    Rectangle()
                        .frame(width: 80,height: 15)
                        .opacity(0.2)
                        .padding(.bottom)
                        .foregroundColor(.gray)
                }
                Spacer()
                
            }
        }.frame(height: 100)
    }
}

struct EventTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        EventTemplateView()
    }
}
