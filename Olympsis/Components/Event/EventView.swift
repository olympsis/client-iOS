//
//  EventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI

/// A view that shows an event's data at a glance. A list item.
struct EventView: View {
    
    @State var event: Event
    @State private var status: LOADING_STATE = .loading
    @State private var showDetails = false
    @EnvironmentObject private var session:SessionStore
    
    private var title: String {
        guard let title = event.title else {
            return "Event"
        }
        return title
    }
    
    private var imageURL: String {
        guard let img = event.imageURL else {
            return ""
        }
        return img
    }
    
    private var fieldName: String {
        guard let field = event.fieldData else {
            guard let field = event.field,
                  let name = field.name else {
                return ""
            }
            return name
        }
        return field.name
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
                        VStack(alignment: .leading){
                            Text(title)
                                .font(.custom("Helvetica-Nue", size: 20))
                                .bold()
                                .frame(height: 20)
                                .padding(.top)
                                .foregroundColor(.primary)
                            
                            Text(fieldName)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            Spacer()
                            if event.type == "tournament" {
                                Text("Tournament")
                                    .font(.caption)
                                    .padding(.bottom)
                                    .foregroundStyle(Color("color-tert"))
                            }
                        }
                        Spacer()
                        _TrailingView(event: $event)
                    }
                }.padding(.horizontal)
            }.frame(height: 100)
        }
        .clipShape(Rectangle())
            .background {
                Rectangle()
                    .foregroundStyle(Color("background"))
            }
        .fullScreenCover(isPresented: $showDetails) {
            EventViewExt(event: $event)
                .presentationDetents([.large])
        }
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
    
    var minParticipantsCount: Int {
        guard let minParticipants = event.minParticipants else {
            return 0
        }
        return minParticipants
    }
    
    var iconColor: Color {
        if (minParticipantsCount != 0) && (participantsCount != 0) && (participantsCount < minParticipantsCount) {
            return .yellow
        } else {
            return Color("color-prime")
        }
    }
    
    var body: some View {
        VStack (alignment: .trailing){
            if event.actualStopTime != nil {
                VStack (alignment: .trailing){
                    HStack {
                        Text("Ended")
                            .bold()
                            .font(.callout)
                    }.foregroundStyle(.gray)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            } else if event.actualStartTime != nil {
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
                    Text(event.timeToString())
                        .bold()
                        .font(.callout)
                        .foregroundColor(.primary)
                    
                    Text(event.timeDifferenceToString())
                        .foregroundColor(.primary)
                }.padding(.bottom, 5)
            }
            
            HStack {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(iconColor)
                Text("\(participantsCount)")
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    EventView(event: EVENTS[0])
        .environmentObject(SessionStore())
}
