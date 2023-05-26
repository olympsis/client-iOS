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
    
    func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(field.location.coordinates[0]),\(field.location.coordinates[1])")! as URL)
    }
    
    var body: some View {
        VStack {
            
            //MARK: - Top view
            HStack{
                Spacer()
                
                Menu{
                    Button(action:{self.showDetail.toggle()}){
                        Label("View Details", systemImage: "info.circle")
                    }
                    Button(action:{}){
                        Label("Report an Issue", systemImage: "exclamationmark.shield")
                    }
                }label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .padding(.trailing)
                        .foregroundColor(Color(uiColor: .label))
                }
            }.padding(.bottom, 5)
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
                    Text(field.city + ", ")
                        .foregroundColor(.gray)
                        .font(.body)
                    + Text(field.state)
                        .foregroundColor(.gray)
                        .font(.body)
                    
                    Text(field.name)
                        .font(.title2)
                        .bold()
                    
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
        }.fullScreenCover(isPresented: $showDetail) {
            FieldDetailView(field: field, events: $session.events)
        }
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        FieldView(field: FIELDS[0])
            .environmentObject(SessionStore())
    }
}
