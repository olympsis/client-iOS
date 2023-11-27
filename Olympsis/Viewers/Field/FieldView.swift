//
//  FieldView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI

import SwiftUI

struct FieldView: View {
    
    @State var field: Field
    @State var showDetail = false // show field view detail
    @State var showReport = false // show make a report view
    @EnvironmentObject var session:SessionStore
    
    var fieldCityString: String {
        return field.city + ", " + field.state
    }
    
    func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[0]),\(field.location.coordinates[1])")! as URL)
    }
    
    var body: some View {
        VStack {
            //MARK: - ASYNC Image
            VStack {
                AsyncImage(url: URL(string: GenerateImageURL(field.images[0]))){ phase in
                    if let image = phase.image {
                        image // Displays the loaded image.
                            .resizable()
                            .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .cornerRadius(10)
                    } else if phase.error != nil {
                        ZStack {
                            Color.gray // Indicates an error.
                                .cornerRadius(10)
                                .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                            Image(systemName: "exclamationmark.circle")
                        }
                    } else {
                        ZStack {
                            Color.gray // Acts as a placeholder.
                                .cornerRadius(10)
                                .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                            ProgressView()
                        }
                    }
                }
            }.frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
            
            //MARK: - Buttom view
            HStack{
                VStack(alignment: .leading){
                    Text(fieldCityString)
                        .foregroundColor(.gray)
                        .font(.body)
                    
                    Text(field.name)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                    
                }.padding(.leading)
                    .frame(height: 45)
                Spacer()
                HStack {
                    Button(action:{leadToMaps()}){
                        ZStack{
                            Image(systemName: "car")
                                .resizable()
                                .frame(width: 25, height: 20)
                                .foregroundColor(.primary)
                                .imageScale(.large)
                        }.padding(.trailing)
                    }
                }.frame(height: 40)
                
                
            }
            .sheet(isPresented: $showDetail) {
                FieldViewExt(field: field)
                    .presentationDetents([.large])
            }
        }.onTapGesture {
            self.showDetail.toggle()
        }
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        FieldView(field: FIELDS[0])
            .environmentObject(SessionStore())
    }
}
