//
//  PickUsername.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import os
import SwiftUI
import Combine

struct UserDataCreation: View {
    
    enum USERNAME_STATUS {
        case pending
        case invalid
        case unknown
        case available
        case unavailable
    }
    
    @Binding var currentView: AuthTab
    @FocusState private var isFocused: Bool
    
    @State private var selectedSports = [SPORTS]()
    @State private var status: LOADING_STATE = .pending
    @State private var continueStatus: LOADING_STATE = .pending
    @State private var uStatus: USERNAME_STATUS = .pending
    
    @StateObject private var viewModel = UsernameSearchViewModel()
    
    @AppStorage("auth_type") private var authType: USER_STATUS?
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    var cacheService = CacheService()
    var userObserver = UserObserver()
    var log = Logger(subsystem: "com.olympsis.client", category: "pick_username_view")
    
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
    
    func handleFailure() {
        continueStatus = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            continueStatus = .pending
        }
    }
    
    func handleSuccess() {
        continueStatus = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            authType = nil
            authStatus = .authenticated
        }
    }
    
    func createUserData() async {
        guard uStatus == .available else {
            handleFailure()
            return
        }
        
        continueStatus = .loading
        let sports = selectedSports.map({ return $0.rawValue })
        do {
            guard let data = try await userObserver.createUserData(username: viewModel.debouncedSearchText, sports: sports) else {
                handleFailure()
                return
            }
            cacheService.cacheUser(user: data)
            handleSuccess()
        } catch {
            log.error("Failed to create user: \(error.localizedDescription)")
            handleFailure()
            return
        }
    }
    
    /// Checks the backend to see if the username is available
    func isUsernameAvailable() async -> Bool {
        do {
            guard validateInput(viewModel.debouncedSearchText) else {
                handleInvalidError()
                return false
            }
            
            status = .loading
            
            let available = try await self.userObserver.UsernameAvailability(name: viewModel.debouncedSearchText)
            guard available == true else {
                handleUnavailableError()
                return false
            }
            
            handleAvailable()
            return true
        } catch {
            handleUnknownFaillureError()
            self.log.error("Failed to check username's availability: \(error.localizedDescription)")
            return false
        }
    }
    
    var body: some View {
        VStack {
            // title
            VStack {
                Text("Getting to know you")
                    .font(.custom("ITCAvantGardeStd-Bk", size: 25, relativeTo: .title2))
                    .fontWeight(.medium)
                Text("What's your handle? Favorite sports?")
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
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("background"))
                        TextField("", text: $viewModel.searchText)
                            .focused($isFocused)
                            .padding(.horizontal)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.search)
                            .onSubmit {
                                Task {
                                    status = .pending
                                    uStatus = .pending
                                    _ = await isUsernameAvailable()
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                            .onChange(of: viewModel.debouncedSearchText) { _, newValue in
                                if !newValue.isEmpty && continueStatus != .loading {
                                    Task {
                                        status = .pending
                                        uStatus = .pending
                                        _ = await isUsernameAvailable()
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
                            .disabled(status == .loading || continueStatus == .loading)
                            
                    }
                    .frame(height: 45)
                    .padding(.horizontal)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("background"))
                            .frame(width: 45, height: 45)
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
            
            
            VStack(alignment: .leading) {
                Text("Favorite Sports")
                    
                    .font(.title3)
                Text("The sports you like to play or sports you are learning")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .padding(.bottom)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.fixed(75)), GridItem(.fixed(75)), GridItem(.fixed(75)), GridItem(.fixed(75))], alignment: .center) {
                        ForEach(SPORTS.allCases, id: \.self) { sport in
                            SportView(sport: sport, scale: .Medium)
                                .overlay {
                                    if (selectedSports.contains(sport)) {
                                        Circle().stroke(Color("color-prime"), lineWidth: 2)
                                    }
                                }
                                .onTapGesture {
                                    if (selectedSports.contains(sport)) {
                                        selectedSports.removeAll(where: { $0 == sport })
                                    } else {
                                        self.selectedSports.append(sport)
                                    }
                                }
                        }
                    }
                }
            }.padding(.all)
            
            Spacer()
            
            // action button
            Button(action: { Task { await createUserData() } }){
                LoadingButton(text: "Continue", status: $continueStatus)
            }
            .padding(.bottom)
            .disabled(!(status == .success && uStatus == .available) || continueStatus == .loading)
        }
    }
}

struct PickUsername_Previews: PreviewProvider {
    static var previews: some View {
        UserDataCreation(currentView: .constant(.username))
    }
}


class UsernameSearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var debouncedSearchText: String = ""

   private var cancellables = Set<AnyCancellable>()

   init() {
       $searchText
           .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
           .removeDuplicates()
           .assign(to: \.debouncedSearchText, on: self)
           .store(in: &cancellables)
   }
}
