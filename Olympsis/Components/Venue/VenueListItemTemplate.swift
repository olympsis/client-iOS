//
//  FieldViewTemplate.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI

struct VenueListItemTemplate: View {
    var body: some View {
        VStack {
            if UIDevice.current.userInterfaceIdiom == .pad {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 500, height: 300, alignment: .center)
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
            }
            //MARK: - Buttom view
            HStack {
                VStack(alignment: .leading){
                    Text("Example City, State")
                        .foregroundColor(.gray)
                        .font(.body)
                    
                    Text("Example Venue Name")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                    
                }.padding(.leading)
                    .frame(height: 45)
                Spacer()
                HStack {
                    ZStack{
                        Image(systemName: "car")
                            .resizable()
                            .frame(width: 25, height: 20)
                            .foregroundColor(.primary)
                            .imageScale(.large)
                    }.padding(.trailing)
                }.frame(height: 40)
                
                
            }
        }.redacted(reason: .placeholder)
    }
}

struct FieldViewTemplate_Previews: PreviewProvider {
    static var previews: some View {
        VenueListItemTemplate()
    }
}
