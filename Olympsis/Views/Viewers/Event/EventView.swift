//
//  EventView.swift
//  Olympsis
//
//  This is the small event view. Shows event data at a glance
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

struct EventView: View {
    
    @State var event: Event
    @State var status: LOADING_STATE = .loading
    @State var showDetails = false
    @EnvironmentObject var session:SessionStore
    
    var title: String {
        guard let title = event.title else {
            return "Event"
        }
        return title
    }
    
    var eventBody: String {
        guard let body = event.body else {
            return "Event Body"
        }
        return body
    }
    
    var imageURL: String {
        guard let img = event.imageURL else {
            return ""
        }
        return img
    }
    
    var fieldName: String {
        guard let data = event.data,
              let field = data.field else {
            return "Field Name"
        }
        return field.name
    }
    
    var startTime: Int64 {
        guard let time = event.startTime else {
            return 0
        }
        return time
    }
    
    var body: some View {
        Button(action:{ self.showDetails.toggle() }) {
            VStack {
                VStack(alignment: .leading){
                    HStack {
                        Image(imageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.leading)
                        VStack(alignment: .leading){
                            Text(title)
                                .font(.custom("Helvetica-Nue", size: 20))
                                .bold()
                                .frame(height: 20)
                                .padding(.top)
                                .foregroundColor(.primary)
                            
                            Text(fieldName)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        Spacer()
                        _TrailingView(event: $event)
                            .padding(.trailing)
                    }
                }
            }.frame(height: 100)
        }
        .clipShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color("background"))
                    .padding(.horizontal, 5)
            }
        .sheet(isPresented: $showDetails) {
            EventViewExt(event: $event)
                .presentationDetents([.large])
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: EVENTS[0]).environmentObject(SessionStore())
    }
}

/// Trailing view for Event view.
/// Contains the start date and time and participants view.
struct _TrailingView: View {
    
    @Binding var event: Event
    
    var participantsCount: Int {
        guard let participants = event.participants else {
            return 0
        }
        return participants.count
    }
    
    var body: some View {
        VStack (alignment: .trailing){
            if event.actualStartTime != nil {
                VStack (alignment: .trailing){
                    HStack {
                        Circle()
                            .frame(width: 10, height: 10)
                        
                        Text("Live")
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.red)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            } else {
                VStack (alignment: .trailing){
                    Text(event.dayToString())
                        .bold()
                        .font(.callout)
                        .foregroundColor(.primary)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            }
            
            HStack {
                Image(systemName: "person.3.sequence")
                    .foregroundColor(Color("color-prime"))
                Text("\(participantsCount)")
                    .foregroundColor(.primary)
            }
        }
    }
}
