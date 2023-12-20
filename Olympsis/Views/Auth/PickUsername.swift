//
//  PickUsername.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import os
import SwiftUI

struct PickUsername: View {
    
    enum USERNAME_STATUS {
        case pending
        case invalid
        case unknown
        case available
        case unavailable
    }
    
    @Binding var currentView: AuthTab
    @FocusState private var isFocused: Bool
    @State private var username: String = ""
    @State private var status: LOADING_STATE = .pending
    @State private var uStatus: USERNAME_STATUS = .pending
    
    @State private var cacheService = CacheService()
    @State private var userObserver = UserObserver()
    
    var log = Logger(subsystem: "com.josephlabs.olympsis", category: "pick_username_view")
    
    /// Validates the username input to make sure it's safe
    func validateInput(_ input: String) -> Bool {
        let regex = "^[a-zA-Z0-9]{5,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
    
    func handleAvailable() {
        status = .success
        uStatus = .available
    }
    
    func handleInvalidError() {
        status = .failure
        uStatus = .invalid
    }
    
    func handleUnavailableError () {
        status = .failure
        uStatus = .unavailable
    }
    
    func handleUnknownFaillureError() {
        status = .failure
        uStatus = .unknown
    }
    
    /// Checks the backend to see if the username is available
    func isUsernameAvailable() async {
        do {
            guard validateInput(username) else {
                handleInvalidError()
                return
            }
            
            status = .loading
            
            let available = try await self.userObserver.UsernameAvailability(name: username)
            guard available == true else {
                handleUnavailableError()
                return
            }
            
            handleAvailable()
        } catch {
            handleUnknownFaillureError()
            self.log.error("failed to check username's availability: \(error.localizedDescription)")
        }
    }
    
    /// Stores username into cache
    func storeUsername() {
        guard var user = cacheService.fetchUser() else {
            log.error("failed to fetch user data from cache")
            handleUnknownFaillureError()
            return
        }
        user.username = username
        cacheService.cacheUser(user: user)
        currentView = .sports
    }
    
    var body: some View {
        VStack {
            // title
            VStack {
                Text("Pick a Username")
                    .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                    .fontWeight(.medium)
                Text("What's your handle?")
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .font(.callout)
            }.frame(width: SCREEN_WIDTH)
            .padding(.horizontal)
                .padding(.vertical)
                .background {
                    Rectangle()
                        .foregroundStyle(Color("background"))
                        .ignoresSafeArea(.all)
                        .frame(width: SCREEN_WIDTH)
                }
                
            // textfield
            VStack(alignment: .leading) {
                Text("username")
                    .padding(.leading)
                    .font(.title3)
                HStack {
                    ZStack {
                        Rectangle()
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color("color-prime"))
                        TextField("", text: $username)
                            .focused($isFocused)
                            .padding(.horizontal)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.search)
                            .onSubmit {
                                Task(priority: .high) {
                                    await isUsernameAvailable()
                                }
                            }
                            .onChange(of: username, perform: { _ in
                                status = .pending
                                uStatus = .pending
                            })
                            
                    }.frame(height: 45)
                        .padding(.horizontal)
                    
                    ZStack {
                        Rectangle()
                            .stroke(lineWidth: 1)
                            .frame(width: 45, height: 45)
                            .foregroundColor(Color("color-prime"))
                            .overlay {
                                switch status {
                                case .pending:
                                    Image(systemName: "questionmark")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                        .animation(.easeInOut, value: status)
                                case .loading:
                                    ProgressView()
                                        .animation(.easeInOut, value: status)
                                case .success:
                                    Image(systemName: "checkmark")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .animation(.easeInOut, value: status)
                                case .failure:
                                    Image(systemName: "xmark")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                        .animation(.easeInOut, value: status)
                                }
                            }
                            .padding(.trailing)
                    }
                }
                
                if uStatus == .pending || uStatus == .invalid {
                    // cautionary text
                    Text("Must be between 5 and 15 characters and contain no special characters to be valid")
                        .font(.caption2)
                        .foregroundColor(uStatus == .invalid ? .red : .gray)
                        .padding(.horizontal)
                        .animation(.easeInOut, value: uStatus)
                } else if uStatus == .unavailable {
                    // cautionary text
                    Text("Username is taken. Please try another...")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.leading)
                        .animation(.easeInOut, value: uStatus)
                } else if uStatus == .unknown {
                    // cautionary text
                    Text("Unknown error has occured")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.leading)
                        .animation(.easeInOut, value: uStatus)
                }
                
            }.padding(.top, 50)
            
            Spacer()
            
            // action button
            Button(action: { storeUsername() }){
                SimpleButtonLabel(text: "continue")
            }
            .padding(.bottom)
            .disabled(!(status == .success && uStatus == .available))
        }
    }
}

struct PickUsername_Previews: PreviewProvider {
    static var previews: some View {
        PickUsername(currentView: .constant(.username))
    }
}
