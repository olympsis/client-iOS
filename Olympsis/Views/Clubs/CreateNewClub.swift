//
//  CreateNewClub.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/16/22.
//

import SwiftUI
import AlertToast

struct Rule: Identifiable {
    let id = UUID()
    let text: String
}

struct CreateNewClub: View {
    
    enum Sports: String, CaseIterable {
        case soccer = "soccer"
        case basketball = "basketball"
        case tennis = "tennis"
    }
    
    @State private var clubName: String = ""
    @State private var description: String = ""
    @State private var isPrivate: Bool = false
    @State private var isVisible: Bool = true
    @State private var sport: String   = "soccer"
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    @State private var imageURL: String = ""
    @State private var newRule: String = ""
    @State private var rules: [String] = [String]()
    
    @State private var showToast = false
    
    @StateObject private var clubObserver = ClubObserver()
    
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack (alignment: .leading){
                    HStack {
                        Text(clubName)
                            .font(.custom("ITCAvantGardeStd-Bold", size: 35, relativeTo: .largeTitle))
                        .padding(.bottom, 50)
                        Spacer()
                        Button(action:{self.presentationMode.wrappedValue.dismiss()}) {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Text("Club Name:")
                        .font(.title3)
                        .bold()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextField("type here", text: $clubName)
                            .padding(.leading)
                    }.frame(height: 40)
                    Text("Description:")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.primary)
                            .opacity(0.1)
                        TextEditor(text: $description)
                            .scrollContentBackground(.hidden)
                        .frame(height: 200)
                    }
                    
                    // MARK: - Sports picker
                    VStack(alignment: .leading){
                        Text("Sport")
                            .font(.title3)
                            .bold()

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.primary)
                                .opacity(0.1)
                                .frame(height: 40)
                            Picker(selection: $sport, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                                ForEach(Sports.allCases, id: \.rawValue) { sport in
                                    Text(sport.rawValue).tag(sport.rawValue)
                                }
                            }.frame(width: SCREEN_WIDTH/2)
                                .tint(Color("primary-color"))
                        }
                    }.padding(.top)
                        .frame(width: SCREEN_WIDTH-25)
                    
                    Toggle(isOn: $isPrivate) {
                        Text("isPrivate")
                            .font(.title3)
                            .bold()
                    }.frame(width: SCREEN_WIDTH-30, height: 40)
                        .tint(Color("secondary-color"))
                    
                    Toggle(isOn: $isVisible) {
                        Text("isVisible")
                            .font(.title3)
                            .bold()
                    }.frame(width: SCREEN_WIDTH-30, height: 40)
                        .tint(Color("secondary-color"))
                    
                    HStack {
                        Text("Club Image")
                            .font(.title3)
                            .bold()
                        Spacer()
                        Button(action:{}){
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 100, height: 30)
                                    .foregroundColor(Color("secondary-color"))
                                Text("upload")
                                    .foregroundColor(.white)
                                    .frame(height: 30)
                            }
                        }
                    }.frame(height: 40)

                    VStack(alignment: .leading){
                        Text("Rules:")
                            .font(.title3)
                            .bold()
                            .padding(.top)

                        ForEach($rules, id: \.self) { r in
                                    HStack {
                                        Text(" * ")
                                        Text(r.wrappedValue)
                                            .padding(.all)
                                    }
                            }
                        
                        HStack {
                            TextField("new rule", text: $newRule)
                            Button(action:{
                                rules.append(newRule)
                                newRule = ""
                            }){
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 60, height: 25)
                                        .foregroundColor(Color("secondary-color"))
                                    Text("add")
                                        .foregroundColor(.white)
                                        .frame(height: 30)
                                }
                            }
                        }.padding(.bottom, 50)
                        
                        VStack(alignment: .center){
                            Button(action: {
                                Task {
                                    let c = ClubDao(_name: clubName, _description: description, _sport: sport, _city: city, _state: state, _country: country, _imageURL: imageURL, _isPrivate: isPrivate, _isVisible: isVisible, _rules: rules)
                                    let club = try await clubObserver.createClub(dao: c)
                                    clubObserver.myClubs.append(club)
                                    showToast = true
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 200, height: 40)
                                        .foregroundColor(Color("secondary-color"))
                                    Text("Create Club")
                                        .foregroundColor(.white)
                                }
                            }
                        }.frame(width: SCREEN_WIDTH-25)
                    }
                }
            }.frame(width: SCREEN_WIDTH-25)
                .toast(isPresenting: $showToast, alert: {
                    AlertToast(displayMode: .banner(.pop), type: .regular, title: "Club Created!", style: .style(titleColor: .green, titleFont: .body))
                }, completion: {
                    self.presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

struct CreateNewClub_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewClub().environmentObject(SessionStore())
    }
}
