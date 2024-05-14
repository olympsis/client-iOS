//
//  FieldView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI

import SwiftUI

struct VenueListItem: View {
    
    @State var venue: Field
    @State var showDetail = false // show field view detail
    @State var showReport = false // show make a report view
    @EnvironmentObject var session:SessionStore
    
    var fieldCityString: String {
        return venue.city + ", " + venue.state
    }
    
    func leadToMaps(){
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?daddr=\(venue.location.coordinates[1]),\(venue.location.coordinates[0])")! as URL)
    }
    
    var body: some View {
        VStack {
            //MARK: - ASYNC Image
            VStack {
                AsyncImage(url: URL(string: GenerateImageURL(venue.images[0]))){ phase in
                    if let image = phase.image {
                        image // Displays the loaded image.
                            .resizable()
                            .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } else if phase.error != nil {
                        ZStack {
                            Color.gray // Indicates an error.
                                .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                            Image(systemName: "exclamationmark.circle")
                        }
                    } else {
                        ZStack {
                            Color.gray // Acts as a placeholder.
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
                    
                    Text(venue.name)
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
                Venue(venue: venue)
                    .presentationDetents([.large])
            }
        }.onTapGesture {
            self.showDetail.toggle()
        }
    }
}

struct FieldView_Previews: PreviewProvider {
    static var previews: some View {
        VenueListItem(venue: FIELDS[0])
            .environmentObject(SessionStore())
    }
}
