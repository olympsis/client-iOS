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
    @State var showDetail = false
    @State var showReport = false
    
    func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[0]),\(field.location.coordinates[1])")! as URL)
    }
    
    var body: some View {
        VStack {
            
            //MARK: - Top view
            HStack{
                Spacer()

                Menu{
                    Button(action:{}){
                        Label("Report an Issue", systemImage: "exclamationmark.shield")
                    }
                }label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .frame(width: 25, height: 5)
                        .padding(.trailing)
                        .foregroundColor(Color(uiColor: .label))
                }
            }
            //MARK: - ASYNC Image
            ZStack(alignment: .top){
                AsyncImage(url: URL(string: field.images[0])){ phase in
                    if let image = phase.image {
                            image // Displays the loaded image.
                                .resizable()
                                .scaledToFit()
                        } else if phase.error != nil {
                            Color.red // Indicates an error.
                        } else {
                            Color.gray // Acts as a placeholder.
                        }
                }.frame(width: SCREEN_WIDTH, height: 300, alignment: .center)
            }
            
            //MARK: - Buttom view
            HStack{
                VStack(alignment: .leading){
                    Text(field.city)
                        .font(.custom("ITCAvantGardeStd-Bold", size: 20))
                        .frame(height: 20)
                    HStack {
                        Text(field.name)
                            .font(.custom("ITCAvantGardeStd-Bk", size: 18))
                        if field.isPublic {
                            Image(systemName: "circle.circle.fill")
                                .padding(.leading)
                                .padding(.bottom, 3)
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle.circle.fill")
                                .padding(.leading)
                                .padding(.bottom, 3)
                                .foregroundColor(.red)
                        }
                    }.frame(height: 20)
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
        }
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        let field = Field(owner: "Brigham Young University", name: "Indoor Practice Facility", images: ["https://storage.googleapis.com/olympsis-1/fields/1309-22-3679.jpg"], location: GeoJSON(type: "Point", coordinates: ["40.249480", "-111.655317"]), city: "Provo", state: "Utah", country: "United States of America", isPublic: false)
        FieldView(field: field).environmentObject(SessionStore())
    }
}
