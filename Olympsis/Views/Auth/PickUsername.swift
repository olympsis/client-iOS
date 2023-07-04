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
        let regex = "^[a-z0-9]{5,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
    
    /// Checks the backend to see if the username is available
    func isUsernameAvailable() async {
        do {
            guard validateInput(username) else {
                status = .failure
                uStatus = .invalid
                return
            }
            status = .loading
            let available = try await self.userObserver.UsernameAvailability(name: username)
            if available {
                status = .success
                uStatus = .available
            } else {
                status = .failure
                uStatus = .unavailable
            }
        } catch {
            status = .failure
            uStatus = .unknown
            self.log.error("failed to check username's availability: \(error.localizedDescription)")
        }
    }
    
    /// Stores username into cache
    func storeUsername() {
        guard var user = cacheService.fetchUser() else {
            log.error("failed to fetch user data from cache")
            uStatus = .unknown
            return
        }
        user.username = username
        cacheService.cacheUser(user: user)
        currentView = .sports
    }
    
    var body: some View {
        VStack {
            // title
            Text("Pick a Username")
                .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                .fontWeight(.medium)
                .padding(.top)
                
            
            // textfield
            VStack(alignment: .leading) {
                Text("username")
                    .padding(.leading)
                    .font(.title3)
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
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
                            
                    }.frame(height: 45)
                        .padding(.horizontal)
                    
                    ZStack {
                        Circle()
                            .frame(width: 45)
                            .foregroundColor(Color("secondary-color"))
                            .opacity(0.3)
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
                    Text("Must be between 5 and 15 characters to be valid")
                        .font(.caption)
                        .foregroundColor(uStatus == .invalid ? .red : .gray)
                        .padding(.leading)
                        .animation(.easeInOut, value: uStatus)
                } else if uStatus == .unavailable {
                    // cautionary text
                    Text("Username is taken. Please try another...")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading)
                        .animation(.easeInOut, value: uStatus)
                } else if uStatus == .unknown {
                    // cautionary text
                    Text("Unknown error has occured")
                        .font(.caption)
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
