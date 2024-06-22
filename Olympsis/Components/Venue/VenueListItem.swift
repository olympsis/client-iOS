//
//  FieldView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/15/22.
//

import SwiftUI
import Kingfisher

struct VenueListItem: View {
    
    @State var venue: Venue
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
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                VStack {
                    VStack {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            if let img = venue.images.first,
                               let url = generateImageURL(img) {
                                KFImage(url)
                                    .placeholder({
                                        ImageLoadingView()
                                    })
                                    .resizable()
                                    .cacheOriginalImage()
                                    .setProcessor(venueImageProcessor(size: CGSize(width: 500*2, height: 300*2)))
                                    .frame(width: 500, height: 300, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                ImageLoadingFailedView()
                                    .frame(width: 500, height: 300, alignment: .center)
                            }
                        } else {
                            if let img = venue.images.first,
                               let url = generateImageURL(img) {
                                KFImage(url)
                                    .placeholder({
                                        ImageLoadingView()
                                    })
                                    .resizable()
                                    .cacheOriginalImage()
                                    .setProcessor(venueImageProcessor(size: CGSize(width: 500*2, height: 300*2)))
                                    .frame(width: 500, height: 300, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                ImageLoadingFailedView()
                                    .frame(width: 500, height: 300, alignment: .center)
                            }
                        }
                        
                    }
                    
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
                        VenueView(venue: venue)
                            .presentationDetents([.large])
                    }
                }.frame(width: 500, alignment: .center)
                
            } else {
                VStack {
                    VStack {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            if let img = venue.images.first,
                               let url = generateImageURL(img) {
                                KFImage(url)
                                    .placeholder({
                                        ImageLoadingView()
                                    })
                                    .resizable()
                                    .cacheOriginalImage()
                                    .setProcessor(venueImageProcessor(size: CGSize(width: SCREEN_WIDTH-20*2, height: 300*2)))
                                    .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                ImageLoadingFailedView()
                                    .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                            }
                        } else {
                            if let img = venue.images.first,
                               let url = generateImageURL(img) {
                                KFImage(url)
                                    .placeholder({
                                        ImageLoadingView()
                                    })
                                    .resizable()
                                    .cacheOriginalImage()
                                    .setProcessor(venueImageProcessor(size: CGSize(width: SCREEN_WIDTH-20*2, height: 300*2)))
                                    .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                ImageLoadingFailedView()
                                    .frame(width: SCREEN_WIDTH-20, height: 300, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    
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
                        VenueView(venue: venue)
                            .presentationDetents([.large])
                    }
                }.frame(width: SCREEN_WIDTH-20, alignment: .center)
            }
        }
        .padding(.horizontal, 10)
        .onTapGesture {
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
