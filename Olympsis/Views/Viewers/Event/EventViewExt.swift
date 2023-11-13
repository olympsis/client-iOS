//
//  EventViewExt.swift
//  Olympsis
//
//  Created by Joel on 7/27/23.
//

import MapKit
import SwiftUI
import CoreLocation

/// A view that shows more detail about a specific event
struct EventViewExt: View {
    
    @Binding var event: Event
    @State private var showParticipants: Bool = false
    @State private var status: LOADING_STATE = .pending
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) private var presentationMode
    
    var eventTitle: String {
        guard let title = event.title else {
            return "Error"
        }
        return title
    }
    
    var eventImage: String {
        guard let img = event.imageURL else {
            return ""
        }
        return  img
    }
    
    var eventBody: String {
        guard let body = event.body else {
            return ""
        }
        return body
    }
    
    var fieldName: String {
        guard let data = event.data,
              let field = data.field else {
            return "No Field"
        }
        return field.name
    }
    
    var fieldLocality: String {
        guard let data = event.data,
              let field = data.field else {
            return "No Field"
        }
        
        return field.city + ", " + field.state
    }
    
    func reloadEvent() async {
        guard let id = event.id,
              let resp = await session.eventObserver.fetchEvent(id: id) else {
            handleFailure()
            return
        }
        
        event = resp
        handleSuccess()
    }
    
    func handleSuccess() {
        status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    func handleFailure() {
        status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            status = .pending
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(eventTitle)
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer()
                
                Button(action: { Task { await reloadEvent() }}) {
                    switch status {
                    case .pending:
                        withAnimation {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.bold)
                        }
                    case .loading:
                        withAnimation {
                            ProgressView()
                        }
                    case .success:
                        withAnimation {
                            Image(systemName: "arrow.clockwise")
                                .fontWeight(.bold)
                        }
                    case .failure:
                        withAnimation {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .imageScale(.medium)
                        }
                    }
                }.clipShape(Circle())
                    .frame(width: 25, height: 20)
                
                Button(action:{ self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }.clipShape(Circle())
                    .frame(width: 25, height: 20)

            }.padding(.horizontal)
                .padding(.top)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    
                    // MARK: - Field Info
                    VStack(alignment: .leading) {
                        Text(fieldName)
                            .font(.title2)
                        Text(fieldLocality)
                    }.padding(.horizontal)
                        .padding(.top, 3)
                    
                    // MARK: - Event Image
                    Image(eventImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // MARK: - Detail/Body
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Details")
                                .font(.title2)
                                .bold()
                            
                            Rectangle()
                                .frame(height: 1)
                            Text(event.timeToString())
                                .font(.callout)
                        }
                        Text(eventBody)
                    }.padding(.all)
                    
                    // MARK: - Middle View
                    EventMiddleView(event: $event)
                    
                    // MARK: - Action Buttons
                    EventActionButtons(event: $event)
                    
                    // MARK: - Participants View
                    EventParticipantsView(event: $event, showParticipants: $showParticipants)
                    
                    // MARK: - Field/Club Detail
                    EventExtDetail(data: event.data)
                }
            }
        }.sheet(isPresented: $showParticipants, content: {
            EventParticipantsViewExt(event: $event)
        })
    }
}

#Preview {
    EventViewExt(event: .constant(EVENTS[0])).environmentObject(SessionStore())
}
