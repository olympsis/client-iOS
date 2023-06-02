//
//  CreateAccount.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/27/22.
//

import os
import SwiftUI

enum UN_STATUS {
    case loading
    case unique
    case error
    case not_unique
}

struct CreateAccount: View {
    
    enum CREATE_ERROR: Error {
        case unexpected
        case noSport
        case noUsername
        case invalidUsername
        case validationInProgress
    }
    
    enum UNAME_STATUS: Int {
        case none
        case found
        case valid
        case invalid
        case searching
    }
    
    @State private var username = ""
    @State private var keyboardIsShown = false
    @State private var status: CREATE_ERROR?
    @State private var uStatus = UNAME_STATUS.none
    @State private var selectedSports:[String] = []
    
    @Binding var currentView: AuthTab
    
    @State private var cacheService = CacheService()
    @State private var userObserver = UserObserver()
    @EnvironmentObject private var session: SessionStore
    @State private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "create_account_view")
    
    func updateSports(sport:String){
        selectedSports.contains(where: {$0 == sport}) ? selectedSports.removeAll(where: {$0 == sport}) : selectedSports.append(sport)
    }
    
    func isSelected(sport:String) -> Bool {
        return selectedSports.contains(where: {$0 == sport})
    }
    
    func validateInput(_ input: String) -> Bool {
        let regex = "^[a-z0-9]{5,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
    
    func validateView() -> CREATE_ERROR? {
        if username == "" {
            return CREATE_ERROR.noUsername
        } else if uStatus == .searching {
            return CREATE_ERROR.validationInProgress
        } else if uStatus == .invalid {
            return CREATE_ERROR.invalidUsername
        } else if selectedSports.count == 0 {
            return CREATE_ERROR.noSport
        }
        return nil
    }
    
    func createUserData() async {
        do {
            let data = try await userObserver.createUserData(username: username, sports: selectedSports)

            if let user = data {
                if var cache = cacheService.fetchUser() {
                    cache.uuid = user.uuid
                    cache.username = user.username
                    cache.sports = user.sports
                    cacheService.cacheUser(user: cache)
                }
            }
        } catch {
            log.error("\(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack {
                    Text("Create your Account")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 50)
                        .padding(.top, 50)
                    
                    VStack(alignment: .leading){
                        Text("username:")
                            .font(.title2)
                            .foregroundColor(status == .noUsername ? .red : .primary)
                        Text("keep between 5 and 15 characters")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray)
                                    .opacity(0.3)
                                HStack {
                                    TextField("", text: $username)
                                        .padding(.leading)
                                        .frame(height: 40)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                        .keyboardType(.alphabet)
                                        .onSubmit {
                                            Task {
                                                if validateInput(username) {
                                                    self.keyboardIsShown = false
                                                    uStatus = .searching
                                                    let res = try await userObserver.CheckUserName(name: username)
                                                    if res {
                                                        uStatus = .valid
                                                    } else {
                                                        uStatus = .found
                                                    }
                                                } else {
                                                    uStatus = .invalid
                                                    status = .noUsername
                                                }
                                            }
                                        }
                                        .disabled(uStatus == .searching ? true : false)
                                        .submitLabel(.search)
                                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                                            withAnimation(.easeInOut){
                                                self.keyboardIsShown = true
                                            }
                                        }
                                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                                            withAnimation(.easeInOut){
                                                self.keyboardIsShown = false
                                            }
                                        }
                                        .onChange(of: username) { newValue in
                                            let isValid = validateInput(newValue)
                                            if !isValid {
                                                status = .noUsername
                                            } else {
                                                status = nil
                                            }
                                        }
                                    HStack {
                                        if uStatus == .searching {
                                            ProgressView()
                                                .padding(.leading, 4)
                                                .padding(.trailing, 10)
                                        } else {
                                            if uStatus != .none {
                                                uStatus == .valid ?
                                                Image(systemName: "checkmark")
                                                    .imageScale(.large)
                                                    .padding(.trailing, 10)
                                                    .foregroundColor(.green)
                                                :
                                                Image(systemName: "xmark")
                                                    .imageScale(.large)
                                                    .padding(.trailing, 10)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                            }
                            if keyboardIsShown {
                                Button(action:{
                                    username = ""
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                }){
                                    Text("cancel")
                                        .foregroundColor(Color("primary-color"))
                                        .font(.body)
                                        .padding(.leading)
                                }
                            }
                        }
                    }.padding(.bottom, 30)
                        .frame(width: SCREEN_WIDTH - 50)
                    
                    VStack(alignment: .leading){
                        Text("pick your favorite sports:")
                            .font(.title2)
                            .foregroundColor(status == .noSport ? .red : .primary)
                        Text("pick at least one sport")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        VStack {
                            ForEach(SPORT.allCases, id: \.self){ _sport in
                                HStack {
                                    Button(action: {updateSports(sport: _sport.rawValue)}){
                                        isSelected(sport: _sport.rawValue) ? Image(systemName: "circle.fill")
                                            .foregroundColor(Color("primary-color")).imageScale(.large) : Image(systemName:"circle")
                                            .foregroundColor(.primary).imageScale(.large)
                                    }
                                    HStack {
                                        Text(_sport.rawValue)
                                            .font(.title3)
                                        Text(_sport.Icon())
                                    }
                                    Spacer()
                                }.padding(.top)
                            }
                        }
                    }.padding(.bottom, 30)
                        .frame(width: SCREEN_WIDTH - 50)
                    
                    
                    Button(action:{
                        status = validateView()
                        if status == nil {
                            Task {
                                await self.createUserData()
                            }
                            withAnimation(.easeOut(duration: 0.2)) {
                                currentView = .permissions
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color("primary-color"))
                                .frame(width: 100, height: 45)
                            Text("create")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                    }.padding(.top, 50)
                    
                }
            }.task {
                // re initializing because the service needs to retrieve new token from the keychain
                userObserver = UserObserver()
            }
        }
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccount(currentView: .constant(.create)).environmentObject(SessionStore())
    }
}


