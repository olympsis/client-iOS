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
    @State private var status: LOADING_STATE = .pending
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
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
    
    var eventField: Field? {
        guard let field = event.fieldData else {
            guard let field = event.field,
                  let name = field.name,
                  let location = field.location else {
                return nil
            }
            return Field(id: "", name: name, owner: Ownership(name: "", type: ""), description: "external", sports: [String](), images: [String](), location: location, city: "", state: "", country: "")
        }
        return field
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
        VStack {
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
                
                Button(action:{ dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                }.clipShape(Circle())
                    .frame(width: 25, height: 20)

            }.padding(.horizontal)
                .padding(.top)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    
                    if event.type == "tournament" {
                        Text("Tournament")
                            .font(.caption)
                            .padding(.leading)
                            .bold()
                            .foregroundStyle(Color("color-tert"))
                    }
                    
                    // MARK: - Organizers Names
                    EventOrganizersView(event: event)
                        .padding(.horizontal)
                        .padding(.bottom, 3)
                        .zIndex(1)
                    
                    // MARK: - Field Info
                    if let field = eventField {
                        EventFieldInfo(field: field)
                            .zIndex(1)
                    }
                        
                    // MARK: - Event Image
                    Image(eventImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .zIndex(0)
                    
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
                    EventParticipantsView(event: $event)
                    
                }
            }
        }
    }
}

#Preview {
    EventViewExt(event: .constant(EVENTS[0]))
        .environmentObject(SessionStore())
}
