//
//  CreateAccount.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import SwiftUI

enum UN_STATUS {
    case loading
    case unique
    case error
    case not_unique
}

struct CreateAccount: View {
    @State var userName: String = ""
    @State var userNameStatus: Bool?
    @State var isSearching = false
    @State var signUpCompleted = false
    @Binding var currentView: AuthTab
    @State var selectedSports:[String] = []
    @StateObject var observer = UserObserver()
    @State var sports = ["soccer", "basketball"]
    
    func updateSports(sport:String){
        selectedSports.contains(where: {$0 == sport}) ? selectedSports.removeAll(where: {$0 == sport}) : selectedSports.append(sport)
    }
    
    func isSelected(sport:String) -> Bool {
        return selectedSports.contains(where: {$0 == sport})
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create your Account")
                    .font(.custom("ITCAvantGardeStd-Demi", size: 30, relativeTo: .largeTitle))
                    .padding(.bottom, 50)
                    .padding(.top, 50)
                
                VStack(alignment: .leading){
                    Text("username")
                        .font(.custom("ITCAvantGardeStd-Md", size: 20, relativeTo: .body))
                    HStack {
                        TextField("", text: $userName)
                            .padding(.leading)
                            .frame(height: 40)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .onSubmit {
                                Task {
                                    isSearching = true
                                    let res = try await observer.CheckUserName(name: userName)
                                    userNameStatus = res
                                    isSearching = false
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.primary, lineWidth: 1)
                            }
                        HStack {
                            if isSearching {
                                ProgressView()
                                    .padding(.leading, 4)
                                    .padding(.trailing, 4)
                            } else {
                                if userNameStatus != nil {
                                    userNameStatus == false ?
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .padding(.trailing, 4)
                                        .foregroundColor(.green)
                                    :
                                    Image(systemName: "x.circle.fill")
                                        .imageScale(.large)
                                        .padding(.trailing, 4)
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "circle")
                                        .padding(.trailing, 4)
                                        .imageScale(.large)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }.padding(.bottom, 30)
                    .frame(width: SCREEN_WIDTH - 50)
                
                VStack(alignment: .leading){
                    Text("pick your favorite sports:")
                        .font(.custom("ITCAvantGardeStd-Md", size: 20, relativeTo: .body))
                    VStack {
                        ForEach($sports, id: \.self){ _sport in
                            HStack {
                                Button(action: {updateSports(sport: _sport.wrappedValue)}){
                                    isSelected(sport: _sport.wrappedValue) ? Image(systemName: "circle.fill")
                                        .foregroundColor(Color("primary-color")).imageScale(.large) : Image(systemName:"circle")
                                        .foregroundColor(.primary).imageScale(.large)
                                }
                                Text(_sport.wrappedValue)
                                    .font(.custom("ITCAvantGardeStd-Bk", size: 20, relativeTo: .body))
                                Spacer()
                            }.padding(.top)
                        }
                    }.padding(.top)
                }.padding(.bottom, 30)
                    .frame(width: SCREEN_WIDTH - 50)
                
                Spacer()
                Button(action:{
                    if !isSearching && userNameStatus != nil && !userNameStatus! {
                        Task {
                            let _ = try await observer.CreateUserData(userName: userName, sports: selectedSports)
                        }
                        withAnimation(.easeOut(duration: 0.2)) {
                            signUpCompleted = true 
                            currentView = .permissions
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color("primary-color"))
                            .frame(width: 100, height: 45)
                        Text("signup")
                            .foregroundColor(.white)
                            .font(.custom("ITCAvantGardeStd-bold", size: 20, relativeTo: .body))
                    }
                }.padding(.bottom)
                
            }.onAppear{
                observer.fetchToken()
            }
        }
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccount(currentView: .constant(.create))
    }
}


