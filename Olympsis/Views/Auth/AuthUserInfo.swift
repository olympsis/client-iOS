//
//  AuthUserInfo.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/5/25.
//

import os
import SwiftUI
import Combine

struct AuthUserInfo: View {
    
    @Binding var currentView: AuthTab
    @FocusState private var isFocused: Bool
    

    @State private var birthdate: Date = Date()
    @State private var selectedGender: Gender? = nil
    
    @State private var infoError: INFO_ERROR? = .none
    @State private var state: LOADING_STATE = .pending
    
    @State private var usernameText: String = ""
    @State private var usernameStatus: VIEW_STATE = .pending
    
    @StateObject private var viewModel = UsernameSearchViewModel()
    
    private let log = Logger(
        subsystem: "com.olympsis.client", category: "user_info_view"
    )
    
    private var minimumAge: Date {
        Calendar.current.date(byAdding: .year, value: -12, to: Date()) ?? Date()
    }
    
    @Environment(SessionStore.self) private var session
    
    enum USERNAME_STATUS {
        case pending
        case invalid
        case unknown
        case available
        case unavailable
    }
    
    enum INFO_ERROR {
        case birthday
        case gender
    }
    
    @MainActor
    func updateUser() {
        guard state != .loading else { return }
        
        Task(priority: .userInitiated) { @MainActor in
            guard usernameStatus == .success,
                  birthdate < minimumAge,
                  selectedGender != nil else {
                infoError = nil
                
                if birthdate > minimumAge {
                    infoError = .birthday
                    return
                }
                
                if selectedGender == nil {
                    infoError = .gender
                    return
                }
                
                if viewModel.debouncedSearchText.isEmpty {
                    handleUsernameStatus(.invalid)
                }
                return
            }
            
            state = .loading
            
            // Update user data
            var dao = UserDao()
            dao.birthdate = birthdate
            dao.gender = selectedGender
            dao.username = viewModel.debouncedSearchText
                .lowercased()
                .trimmingCharacters(in: .newlines)
                .trimmingCharacters(in: .illegalCharacters)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            _ = await session.userObserver.UpdateUserData(update: dao)
            
            state = .success
            currentView = .sports
        }
    }
    
    @MainActor
    func validateInput(_ input: String) -> Bool {
        let regex = "^[a-zA-Z0-9]{5,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
    
    @MainActor
    func handleUsernameStatus(_ status: USERNAME_STATUS) {
        switch status {
        case .available:
            usernameStatus = .success
        case .invalid:
            usernameStatus = .failure
            usernameText = "Must be between 5 and 15 characters and contain no special characters to be valid"
        case .unavailable:
            usernameStatus = .failure
            usernameText = "Username is taken. Please try another..."
        default:
            usernameStatus = .failure
            usernameText = "Unknown error has occured..."
        }
    }
    
    @MainActor
    func isUsernameAvailable() async -> Bool {
        do {
            guard validateInput(viewModel.debouncedSearchText) else {
                handleUsernameStatus(.invalid)
                return false
            }
            
            let available = try await self.session.userObserver.UsernameAvailability(name: viewModel.debouncedSearchText)
            guard available == true else {
                handleUsernameStatus(.unavailable)
                return false
            }
            
            handleUsernameStatus(.available)
            return true
        } catch {
            handleUsernameStatus(.unknown)
            self.log.error("Failed to check username's availability: \(error.localizedDescription)")
            return false
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 5) {
                Text(String(localized: "auth-user-info-title", table: "Onboarding"))
                    .font(.custom("Archivo-Bold", size: 25, relativeTo: .title))
                
                Text(String(localized: "auth-user-info-sub-title", table: "Onboarding"))
                    .padding(.bottom)
                
            }.padding(.horizontal)
            
            Rectangle()
                .frame(height: 1)
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    Text(String(localized: "auth-user-info-birthdate", table: "Onboarding"))
                        .font(.headline)
                        .foregroundStyle(infoError == .birthday ? Color.red : Color.primary)
                    
                    DatePicker(String(localized: "select-your-birthdate", table: "Onboarding"), selection: $birthdate, displayedComponents: [.date])
                        
                }.padding([.top, .horizontal])
                
                VStack(alignment: .leading) {
                    Text(String(localized: "gender", table: "General"))
                        .font(.headline)
                        .foregroundStyle(infoError == .gender ? Color.red : Color.primary)
                    
                    ForEach(Gender.allCases, id: \.self) { gender in
                        HStack {
                            Button(action: { withAnimation(.easeInOut) { selectedGender = gender } }) {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .background(.regularMaterial)
                                    .foregroundStyle(selectedGender == gender ? Color.Brand.primary : .clear)
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 3))
                                    .clipShape(Circle())
                            }
                            
                            Text(gender.displayName().capitalized)
                        }
                    }
                    
                    HStack {
                        Spacer()
                    }
                }
                .padding([.top, .horizontal])
                
                VStack(alignment: .leading) {
                    Text(String(localized: "username", table: "General"))
                        .font(.headline)
                        .foregroundStyle(usernameStatus == .failure ? Color.red : Color.primary)
                    
                    TextField(String(localized: "type-username-here", table: "Onboarding"), text: $viewModel.searchText)
                        .padding(.all)
                        .modifier(InputFieldModifier())
                        .overlay(alignment: .trailing) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.clear)
                                .frame(width: 45, height: 45)
                                .overlay {
                                    switch usernameStatus {
                                    case .pending:
                                        Image(systemName: "questionmark")
                                            .imageScale(.large)
                                            .fontWeight(.bold)
                                            .foregroundColor(.gray)
                                            .animation(.easeInOut, value: usernameStatus)
                                    case .loading:
                                        ProgressView()
                                            .animation(.easeInOut, value: usernameStatus)
                                    case .success:
                                        Image(systemName: "checkmark")
                                            .imageScale(.large)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                            .animation(.easeInOut, value: usernameStatus)
                                    case .failure:
                                        Image(systemName: "xmark")
                                            .imageScale(.large)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .animation(.easeInOut, value: usernameStatus)
                                    }
                                }
                                .padding(.trailing, 10)
                        }
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.search)
                        .onSubmit {
                            Task {
                                state = .pending
                                usernameStatus = .pending
                                _ = await isUsernameAvailable()
                                isFocused = false
                            }
                        }
                        .onChange(of: viewModel.debouncedSearchText) { _, newValue in
                            if !newValue.isEmpty && state != .loading {
                                Task {
                                    state = .pending
                                    usernameStatus = .pending
                                    _ = await isUsernameAvailable()
                                    isFocused = false
                                }
                            }
                        }
                        .disabled(state == .loading || usernameStatus == .loading)
                    
                    if (usernameStatus == .failure) {
                        Text(usernameText)
                            .font(.caption)
                            .padding(.horizontal)
                            .foregroundStyle(.red)
                    }
                }.padding([.top, .horizontal])
                
                Spacer(minLength: 50)
            }.padding(.top, -8)
            
            Button(action: { updateUser() }) {
                LoadingButton(text: String(localized: "continue", table: "General"), status: $state)
                    .padding(.top, -8)
                    .padding(.horizontal)
            }
        }
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

#Preview {
    AuthUserInfo(currentView: .constant(.info))
        .environment(SessionStore())
}
