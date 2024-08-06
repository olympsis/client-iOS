    //
//  EventSharingView.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/30/24.
//

import SwiftUI
import Kingfisher

struct EventSharingView: View {
    
    var event: Event
    @State private var selectedTemplate: Int = 3
    var imageURL: URL? {
        guard let link = event.imageURL else {
            return nil
        }
        return generateImageURL(link)
    }
    
    var body: some View {
        VStack {
            if let url = imageURL {
                ZStack {
                    KFImage(url)
                        .resizable()
                        .scaleFactor(1)
                        .cropping(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0)))
                        .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
                    
                    VStack {
                        switch selectedTemplate {
                        case 0:
                            HStack {
                                Text(event.title ?? "")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                            }
                            .padding()
                            
                            Spacer()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(event.timeToString())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    if let venue = event.venues?.first {
                                        Text(venue.name ?? "")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            
                        case 1:
                            VStack {
                                Spacer()
                                
                                Text(event.timeToString())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.top, 50)
                                    .italic()
                                
                                Spacer()
                            }
                            .padding()
                            
                            Spacer()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(event.title ?? "")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    if let venue = event.venues?.first {
                                        Text(venue.name ?? "")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                        case 2:
                            VStack {
                                Spacer()
                                Text(event.title ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                if let venue = event.venues?.first {
                                    Text(venue.name ?? "")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                                Text(event.timeToString())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .italic()
                                
                                Spacer()
                            }
                            .padding()
                        case 3:
                            VStack {
                                Spacer()
                                
                                Text(event.timeToString())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .italic()
                                
                                Spacer()
                                
                                Text(event.title ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                if let venue = event.venues?.first {
                                    Text(venue.name ?? "")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding()
                        default:
                            EmptyView()
                        }
                    }
                    .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Image(.whiteLogo)
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                        Spacer()
                    }
                    .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH*(1350.0 / 1080.0), alignment: .center)
                }
            }
            
            Spacer()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], content: {
                ForEach(0..<4, id: \.self) { i in
                    EventSharingTemplateView(template: i)
                        .overlay {
                            if selectedTemplate == i {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.colorPrime, lineWidth: 2)
                            }
                        }
                        .onTapGesture {
                            self.selectedTemplate = i
                        }
                }
            })
        }
    }
}

#Preview {
    EventSharingView(event: EVENTS[0])
}
